import sys
import os
import struct
import xml.etree.ElementTree as ET
import json
import logging
from typing import Dict, List, Optional, Any

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class ItemsLoader:
    def __init__(self, items_xml_path: str):
        self.items: Dict[int, Dict[str, Any]] = {}
        self.load_items(items_xml_path)

    def load_items(self, path: str):
        logging.info(f"Loading items from {path}")
        try:
            tree = ET.parse(path)
            root = tree.getroot()
            for item in root.findall('item'):
                try:
                    if 'fromid' in item.attrib and 'toid' in item.attrib:
                        ids = range(int(item.attrib['fromid']), int(item.attrib['toid']) + 1)
                    else:
                        ids = [int(item.attrib['id'])]

                    props = {}
                    name = item.attrib.get('name', 'unknown')
                    props['name'] = name
                    
                    for attr in item.findall('attribute'):
                        key = attr.attrib['key']
                        value = attr.attrib['value']
                        props[key] = value

                    item_type = "object"
                    is_blocking = False
                    
                    if 'primarytype' in props:
                        ptype = props['primarytype']
                        if 'wall' in ptype:
                            item_type = "wall"
                            is_blocking = True
                        elif 'floor' in ptype or 'tile' in ptype or 'ground' in name:
                            item_type = "floor"
                            
                    if item_type == "object":
                        if "wall" in name:
                            item_type = "wall"
                            is_blocking = True
                        elif "floor" in name or "ground" in name or "grass" in name:
                            item_type = "floor"
                        elif "door" in name:
                            item_type = "door"
                            is_blocking = True

                    props['type'] = item_type
                    props['blocking'] = is_blocking
                    
                    for i in ids:
                        self.items[i] = props
                except:
                    continue
        except Exception as e:
            logging.error(f"Failed to load items: {e}")

    def get_item_props(self, item_id: int) -> Dict[str, Any]:
        return self.items.get(item_id, {"type": "unknown", "blocking": False})

class OTBMParser:
    OTBM_ROOTV1 = 1
    OTBM_MAP_DATA = 2
    OTBM_TILE_AREA = 4
    OTBM_TILE = 5
    OTBM_ITEM = 6
    OTBM_HOUSETILE = 7
    
    NODE_START = 0xFE
    NODE_END = 0xFF
    ESCAPE = 0xFD

    def __init__(self, filepath: str):
        self.filepath = filepath
        self.buffer = b''
        self.pos = 0
        self.tiles = []

    # Unescaping is handled directly in parse() method - no separate function needed
        
    def parse(self, items_loader):
        logging.info(f"Reading OTBM: {self.filepath}")
        with open(self.filepath, 'rb') as f:
            raw_data = f.read()
            
        logging.info("Unescaping data...")
        # OTBM Escape Logic from C++:
        # if (byte == OTBM_ESCAPE) { stream.getU8(); } -> Just skips the escape char?
        # NO. "The escape character is used to signal that the following byte is not a control byte."
        # So we just remove the 0xFD and keep the next byte as is?
        # Actually... "If the byte is 0xFD, discard it and read the next byte as data."
        # This implies: 0xFD 0xFE -> 0xFE (Data), 0xFD 0xFD -> 0xFD (Data), 0xFE (Control).
        
        self.buffer = bytearray()
        i = 0
        length = len(raw_data)
        
        # Check Signature 0 (4 bytes)
        # 0x00 0x00 0x00 0x00 usually?
        # Then Root Node 0xFE ...
        
        # We can't batch replace because 0xFD is the trigger.
        # We'll rely on processing loop.
        
        new_buf = []
        skip_next = False
        for idx, b in enumerate(raw_data):
            if skip_next:
                new_buf.append(b)
                skip_next = False
                continue
            
            if b == self.ESCAPE:
                skip_next = True
            else:
                new_buf.append(b)
        
        self.buffer = bytes(new_buf)
        logging.info(f"Unescaped size: {len(self.buffer)} bytes")
        
        self.pos = 0
        
        # Header (Version check)
        # First 4 bytes might be 0 or 'OTBM'
        if self.buffer[0:4] == b'\x00\x00\x00\x00':
            self.pos = 4
        
        self.recursive_parse(items_loader)
        logging.info(f"Extracted {len(self.tiles)} tiles.")

    def recursive_parse(self, items_loader, parent_type=None, context=None):
        if self.pos >= len(self.buffer): return

        # Check Node Start
        if self.buffer[self.pos] != self.NODE_START:
            # We are likely reading data or aligned wrong.
            # But recursive_parse is called AFTER consuming NODE_START usually?
            # No, let's call it 'at the start of a node'
            return

        self.pos += 1
        node_type = self.buffer[self.pos]
        self.pos += 1
        
        # Context extraction
        current_context = context
        
        if node_type == self.OTBM_ROOTV1:
            self.pos += 4 # version
            self.pos += 2 # width
            self.pos += 2 # height
            self.pos += 4 # major
            self.pos += 4 # minor
            
        elif node_type == self.OTBM_MAP_DATA:
            # Attributes loop
            while True:
                b = self.buffer[self.pos]
                if b == self.NODE_START or b == self.NODE_END:
                    break
                self.pos += 1
                # Attributes are: Byte(Type) + String/Data
                # Description (1) -> u16 len + len bytes
                # ExtFile (2,3,4,5) -> u16 len + len bytes
                if b >= 1 and b <= 5:
                    l = struct.unpack('<H', self.buffer[self.pos:self.pos+2])[0]
                    self.pos += 2 + l
                else:
                    # Unknown attribute, assumed byte length?
                    # This relies on luck if we don't know the spec. 
                    # Assuming only string attributes appear in MapData in this version.
                    pass

        elif node_type == self.OTBM_TILE_AREA:
            x = struct.unpack('<H', self.buffer[self.pos:self.pos+2])[0]
            self.pos += 2
            y = struct.unpack('<H', self.buffer[self.pos:self.pos+2])[0]
            self.pos += 2
            z = self.buffer[self.pos]
            self.pos += 1
            current_context = (x, y, z)

        elif node_type == self.OTBM_TILE or node_type == self.OTBM_HOUSETILE:
            if context:
                bx, by, bz = context
                dx = self.buffer[self.pos]
                self.pos += 1
                dy = self.buffer[self.pos]
                self.pos += 1
                
                rx = bx + dx
                ry = by + dy
                rz = bz
                
                if node_type == self.OTBM_HOUSETILE:
                    self.pos += 4 # House ID
                
                # Tile Attributes
                while True:
                    b = self.buffer[self.pos]
                    if b == self.NODE_START or b == self.NODE_END:
                        break
                    self.pos += 1
                    
                    if b == 0x16: # Flags
                        self.pos += 4
                    elif b == 0x01: # Item
                        sid = struct.unpack('<H', self.buffer[self.pos:self.pos+2])[0]
                        self.pos += 2
                        self.add_tile(rx, ry, rz, sid, items_loader, "floor")
                    else:
                        # Unknown attr?
                        pass
                
                current_context = (rx, ry, rz) # Passed to children (items)

        elif node_type == self.OTBM_ITEM:
            sid = struct.unpack('<H', self.buffer[self.pos:self.pos+2])[0]
            self.pos += 2
            if context and len(context) == 3:
                rx, ry, rz = context
                self.add_tile(rx, ry, rz, sid, items_loader, "object")
            
            # Attributes can be here too?
            # Items often have attributes like count, actionID etc.
            # We must skip them to reach NODE_END safely or Children.
            # Item attributes are a mess to parse without full spec.
            # However, items often nest. 
            pass

        # Process Children
        while True:
            if self.pos >= len(self.buffer): break
            b = self.buffer[self.pos]
            
            if b == self.NODE_END:
                self.pos += 1
                break
            elif b == self.NODE_START:
                self.recursive_parse(items_loader, node_type, current_context)
            else:
                # We are in data? If we are in Item or Tile, we might be hitting attributes we missed?
                # or just skip byte
                self.pos += 1

    def add_tile(self, x, y, z, sid, loader, def_type):
        # Filter for meaningful tiles
        props = loader.get_item_props(sid)
        t = props.get('type', def_type)
        if t == "object" and not props.get('blocking'):
             return # Skip decoration to save space?
             
        self.tiles.append({
            "x": x, "y": y, "z": z,
            "t": t, # s, w, f (short keys)
            "id": sid
        })

if __name__ == "__main__":
    BASE_DIR = r"C:\Users\merca\.gemini\antigravity\scratch\OTSERVER_15X\server"
    ITEMS_XML = os.path.join(BASE_DIR, "data", "items", "items.xml")
    OTBM_FILE = os.path.join(BASE_DIR, "data-otservbr-global", "world", "world.otbm")
    
    OUTPUT_DIR = r"C:\Users\merca\.gemini\antigravity\scratch\OTSERVER_15X\export"
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    items = ItemsLoader(ITEMS_XML)
    parser = OTBMParser(OTBM_FILE)
    try:
        parser.parse(items)
    except Exception as e:
        logging.error(f"Fatal parse error: {e}")
        
    with open(os.path.join(OUTPUT_DIR, "tiles.json"), "w") as f:
        json.dump(parser.tiles, f)

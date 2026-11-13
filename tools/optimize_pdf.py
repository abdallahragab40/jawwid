"""Lossless structural PDF optimization for Jawwid (جَوِّد).
Merges byte-identical image XObjects (same dictionary + same raw stream bytes),
rewrites only the dictionary keys that reference merged duplicates (stream data is
never touched), drops unreferenced objects and packs object streams.
Image data is never re-encoded; content streams are never rewritten."""
import pymupdf, hashlib, re, sys
REF=re.compile(r'\b(\d+) 0 R\b')
def optimize(src,dst):
    d=pymupdf.open(src); remap={}
    while True:
        canon={}; new={}
        for x in range(1,d.xref_length()):
            if x in remap: continue
            try:
                if not d.xref_is_stream(x) or d.xref_get_key(x,'Subtype')[1]!='/Image': continue
            except Exception: continue
            dct=re.sub(r'/Length \d+','',d.xref_object(x,compressed=True))
            k=hashlib.sha256(dct.encode()+b'|'+d.xref_stream_raw(x)).digest()
            if k in canon: new[x]=canon[k]
            else: canon[k]=x
        if not new: break
        remap.update(new)
        sub=lambda s: REF.sub(lambda m: f'{new.get(int(m.group(1)),int(m.group(1)))} 0 R',s)
        for x in range(1,d.xref_length()):
            if x in remap: continue
            try: keys=d.xref_get_keys(x)
            except Exception: continue
            for key in keys:
                if key=='Length': continue
                typ,val=d.xref_get_key(x,key)
                if ' 0 R' not in val: continue
                nv=sub(val)
                if nv!=val: d.xref_set_key(x,key,nv)
    d.save(dst,garbage=3,deflate=True,use_objstms=1)
    return len(remap)
if __name__=='__main__':
    print('merged images:',optimize(sys.argv[1],sys.argv[2]))

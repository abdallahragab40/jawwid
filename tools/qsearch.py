"""Finds a phrase in the Tanzil Uthmani text, ignoring diacritics.
Usage: python3 -I tools/qsearch.py "من هاجر" "انعمت"
"""
import os,re,sys
MARKS=re.compile('[ؐ-ًؚ-ٰٟۖ-ۭ࣓-ࣿـ]')
def norm(s):
    s=MARKS.sub('',s)
    s=re.sub('[آأإٱٲٳ]','ا',s)
    s=s.replace('ءا','ا').replace('ى','ي').replace('ؤ','و').replace('ئ','ي')
    return re.sub(r'\s+',' ',s).strip()
V=[]
TANZIL=os.path.join(os.path.dirname(os.path.abspath(__file__)),'tanzil-quran-uthmani-1.1.txt')
for line in open(TANZIL,encoding='utf-8'):
    if line.startswith('#') or not line.strip(): continue
    s,a,t=line.rstrip('\n').split('|',2); V.append((int(s),int(a),t,norm(t)))
def find(q,limit=6):
    nq=norm(q); out=[]
    for s,a,t,n in V:
        if re.search(r'(^| )'+re.escape(nq)+r'( |$)',n): out.append((s,a,t))
    return out
if __name__=='__main__':
    for q in sys.argv[1:]:
        r=find(q); print(f'## {q}  -> {len(r)} hits')
        for s,a,t in r[:4]: print(f'   {s}:{a}  {t}')

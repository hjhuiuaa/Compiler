"""Differential tests plus an independent Python oracle, with raw evidence."""
from pathlib import Path
import subprocess, json, random, math
ROOT = Path(__file__).resolve().parents[1]
B = ROOT/'build'
def fib(n):
    a,b,i=0,1,1
    out=[0,1]
    while i<n:
        a,b=b,a+b
        out.append(b)
        i+=1
    return out
def features(x,d):
    q=math.trunc(x/d) if d else 0
    r=x-q*d if d else 0
    total=0
    for a in [x,-2,d,0,9]:
        if a==0: break
        if a<0: continue
        total+=a
    return [x+d,x-d,x*d,q,r,(x>0)-(x<0),int(d!=0 and q>1),
            int(d==0 or x!=0),int(d!=0),int(not(x<=d) and x>=0),
            total,math.trunc(((x+0.5)*2-d)/2),-x,d+1,x]
cases=[('fib',[n],fib(n)) for n in [-5,0,1,2,3,5,10,20,30,46]]
pairs=[(x,d) for x in [-100,-7,-1,0,1,7,100] for d in [-100,-3,-1,0,1,3,100]]
rng=random.Random(2410933)
pairs+= [(rng.randint(-100,100),rng.randint(-100,100)) for _ in range(51)]
cases += [('features',[x,d],features(x,d)) for x,d in pairs]
records=[]
for stem,values,want in cases:
    variants=['source-O0','source-O2','ir-O0','ir-O2','asm']
    if stem=='fib': variants+=['c-O0','c-O2']
    expected=''.join(str(v)+'\n' for v in want)
    inp=' '.join(map(str,values))+'\n'
    for variant in variants:
        exe=f'{stem}-{variant}'
        p=subprocess.run(['qemu-riscv64',str(B/exe)],input=inp,
                         capture_output=True,text=True,timeout=5)
        ok=p.returncode==0 and p.stdout==expected
        records.append({'executable':exe,'input':inp,'expected':expected,
                        'stdout':p.stdout,'stderr':p.stderr,
                        'exit_code':p.returncode,'passed':ok})
(B/'test-results.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf-8')
summary={'cases':len(cases),'executions':len(records),'passed':sum(r['passed'] for r in records),
         'failed':sum(not r['passed'] for r in records),
         'fib_cases':10,'feature_cases':100,'seed':2410933}
(B/'test-summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print(json.dumps(summary,indent=2))
assert summary['failed']==0, 'See build/test-results.json for mismatches.'

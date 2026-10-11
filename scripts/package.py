"""Package sources, report and raw verification evidence (no VM or Git files)."""
from pathlib import Path
import hashlib,json,zipfile,subprocess
root=Path(__file__).resolve().parents[1]
excluded={'.git','tmp','__pycache__','third_party'}
latex_aux={'.aux','.log','.out','.toc','.bbl','.blg','.fls','.fdb_latexmk','.synctex.gz'}
obsolete={'report.md','scripts/make_report.py','report-latex/main.pdf'}
files=[]
for p in root.rglob('*'):
    if not p.is_file():
        continue
    rel=p.relative_to(root)
    rel_posix=rel.as_posix()
    if any(x in excluded or x.startswith('render-') for x in rel.parts) or rel_posix in obsolete:
        continue
    if rel.parts[0]=='build':
        keep_build_root={'commands.json','environment.json','test-results.json','test-summary.json'}
        in_text_evidence=len(rel.parts)>1 and rel.parts[1]=='stages' and p.suffix.lower()!='.o'
        if rel.name not in keep_build_root and not in_text_evidence:
            continue
    if any(p.name.endswith(suffix) for suffix in latex_aux):
        continue
    files.append(p)
manifest=root/'evidence/final-manifest.json'
files=[p for p in files if p!=manifest]
hashes={p.relative_to(root).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
originals=['fib.c','fib.sy','fib.ll','fib-sysy.ll','预备工作.md']
unchanged={}
for name in originals:
    upstream=subprocess.check_output(['git','show','HEAD:'+name],cwd=root)
    # Git for Windows may check out LF blobs as CRLF; compare normalized content.
    unchanged[name]=upstream.replace(b'\r\n',b'\n')==(root/name).read_bytes().replace(b'\r\n',b'\n')
assert all(unchanged.values()),unchanged
manifest.write_text(json.dumps({'upstream_commit':'5c88f9d2900a346a87ccc1a0c9719c8c256d6d49',
                               'comparison':'normalized LF (Git checkout may use CRLF)',
                               'upstream_files_unchanged':unchanged,'sha256':hashes},ensure_ascii=False,indent=2),encoding='utf-8')
out=root.parent/'实验一_完整提交包_马禹翔_胡家华.zip'
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in files+[manifest]:z.write(p,'Compiler/'+p.relative_to(root).as_posix())
with zipfile.ZipFile(out) as z:
    assert z.testzip() is None
    print(f'{out}\nFiles: {len(z.namelist())}; Bytes: {out.stat().st_size}')

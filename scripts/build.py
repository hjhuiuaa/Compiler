"""Build real RV64 ELF executables and retain compilation-stage evidence."""
from pathlib import Path
import os, subprocess, json, hashlib

ROOT = Path(__file__).resolve().parents[1]
os.chdir(ROOT)
B = Path('build')
B.mkdir(exist_ok=True)
(B/'stages').mkdir(exist_ok=True)
SYSROOT = Path(os.environ.get('RISCV_SYSROOT', '/opt/riscv-sysroot'))
BUILTINS = next(SYSROOT.rglob('libclang_rt.builtins-riscv64.a'))
CC = ['clang', '--target=riscv64-linux-musl', '--sysroot='+str(SYSROOT),
      '-march=rv64gc', '-mabi=lp64d', '-mcmodel=medany', '-fno-pie',
      '-fno-stack-protector', '-ffp-contract=off']
commands = []
def run(args, output=None, stderr=None):
    args = [str(a) for a in args]
    p = subprocess.run(args, capture_output=True, text=True)
    commands.append({'command': args, 'exit_code': p.returncode, 'stderr': p.stderr})
    (B/'commands.json').write_text(json.dumps(commands, indent=2), encoding='utf-8')
    if output: Path(output).write_text(p.stdout, encoding='utf-8')
    if stderr: Path(stderr).write_text(p.stderr, encoding='utf-8')
    if p.returncode:
        raise RuntimeError(' '.join(args)+'\n'+p.stdout+p.stderr)
    return p.stdout

run(['python3','scripts/port_ir.py'])
versions = {tool: run([tool, '--version']).splitlines()[0]
            for tool in ['clang','ld.lld','llvm-ar','llvm-objdump','qemu-riscv64']}
versions['target'] = 'riscv64-linux-musl / rv64gc / lp64d'
versions['sysroot'] = str(SYSROOT)
versions['course_runtime_sha256'] = hashlib.sha256(Path('runtime/lib/sylib.c').read_bytes()).hexdigest()
(B/'environment.json').write_text(json.dumps(versions,indent=2),encoding='utf-8')
run(CC+['-O2','-c','runtime/lib/sylib.c','-o',B/'sylib.o'])
run(['llvm-ar','rcs', B/'libsysy_riscv.a',B/'sylib.o'])

def link(obj, name):
    # Explicit startup and libc paths avoid any host x86 libraries.
    lib = SYSROOT/'usr/lib'
    run(CC+['-nostdlib','-static','-fuse-ld=lld',
        '-Wl,--no-relax,-e,_start', '-Wl,-Map='+str(B/(name+'.map')),
        lib/'crt1.o',lib/'crti.o',obj,B/'libsysy_riscv.a',lib/'libc.a',BUILTINS,lib/'crtn.o',
        '-o',B/name])

for stem, source in [('fib','fib.sy'),('features','examples/features.sy')]:
    for opt in [0,2]:
        name = f'{stem}-source-O{opt}'
        obj = B/(name+'.o')
        run(CC+['-x','c','-include','include/sysy_decls.h',f'-O{opt}','-c',source,'-o',obj])
        link(obj,name)
        name = f'{stem}-ir-O{opt}'
        obj = B/(name+'.o')
        run(CC+[f'-O{opt}','-c',f'ir/{stem}-riscv.ll','-o',obj])
        link(obj,name)
    obj = B/(stem+'-asm.o')
    run(CC+['-c',f'asm/{stem}-riscv.S','-o',obj])
    link(obj,stem+'-asm')
    run(['llvm-objdump','-dr',obj],B/'stages'/(stem+'-asm.object.txt'))
    run(['llvm-readelf','-h','-A','-s','-r',obj],B/'stages'/(stem+'-asm.elf.txt'))
    run(['llvm-nm',obj],B/'stages'/(stem+'-asm.symbols.txt'))
    run(['llvm-objdump','-d',B/(stem+'-asm')],B/'stages'/(stem+'-asm.linked.txt'))
    run(['llvm-nm',B/(stem+'-asm')],B/'stages'/(stem+'-asm.linked-symbols.txt'))
    run(['llvm-as',f'ir/{stem}-riscv.ll','-o',B/(stem+'.bc')])
    run(['opt','-passes=verify',B/(stem+'.bc'),'-disable-output'])

# Use the team's original C example for a complete frontend-to-linker trace.
run(CC+['-E','fib.c','-o',B/'stages/fib.i'])
run(CC+['-fsyntax-only','-Xclang','-dump-tokens','fib.c'],stderr=B/'stages/fib.tokens.txt')
run(CC+['-fsyntax-only','-Xclang','-ast-dump','fib.c'],output=B/'stages/fib.ast.txt')
for opt in [0,2]:
    run(CC+[f'-O{opt}','-S','-emit-llvm','fib.c','-o',B/f'stages/fib.O{opt}.ll'])
    run(CC+[f'-O{opt}','-S','fib.c','-o',B/f'stages/fib.O{opt}.s'])
    run(CC+['-c',B/f'stages/fib.O{opt}.s','-o',B/f'fib-c-O{opt}.o'])
    link(B/f'fib-c-O{opt}.o',f'fib-c-O{opt}')
run(CC+['-O0','-g','-c','fib.c','-o',B/'stages/fib.debug.o'])
run(['llvm-readelf','-S',B/'stages/fib.debug.o'],B/'stages/fib.debug.sections.txt')
run(['opt','-S','-passes=mem2reg','ir/features-riscv.ll','-o',B/'stages/features.mem2reg.ll'])
objects = sorted(B.glob('*.o'))
run(['llvm-size',*objects],B/'stages/sizes.txt')
run(['llvm-readelf','-h','-l',B/'fib-asm'],B/'stages/fib-executable.elf.txt')
print(json.dumps(versions,indent=2))
print('Built 12 RV64 executables; stage evidence in build/stages.')

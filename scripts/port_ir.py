"""Retarget the teammate's IR without altering the original file or its body."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
text = (root / 'fib-sysy.ll').read_text(encoding='utf-8')
text = re.sub(r'^target datalayout = .*\n', '', text, flags=re.M)
text = re.sub(r'^target triple = .*$', 'target triple = "riscv64-unknown-linux-gnu"', text, flags=re.M)
for name in ('target-cpu', 'target-features', 'tune-cpu'):
    text = re.sub(r' "' + name + r'"="[^"]*"', '', text)
text = re.sub(r'^declare .*@(?:__isoc99_scanf|printf).*\n', '', text, flags=re.M)
(root / 'ir/fib-riscv.ll').write_text('; Ported from fib-sysy.ll; see scripts/port_ir.py.\n' + text, encoding='utf-8')

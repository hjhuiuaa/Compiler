; Ported from fib-sysy.ll; see scripts/port_ir.py.
; ModuleID = 'fib.sy'
source_filename = "fib.sy"
target triple = "riscv64-unknown-linux-gnu"

declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i32 0, ptr %2, align 4
  store i32 1, ptr %3, align 4
  store i32 1, ptr %4, align 4
  %7 = call i32 @getint()
  store i32 %7, ptr %6, align 4
  %8 = load i32, ptr %2, align 4
  call void @putint(i32 %8)
  call void @putch(i32 10)
  %9 = load i32, ptr %3, align 4
  call void @putint(i32 %9)
  call void @putch(i32 10)
  br label %10

10:                                               ; preds = %14, %0
  %11 = load i32, ptr %4, align 4
  %12 = load i32, ptr %6, align 4
  %13 = icmp slt i32 %11, %12
  br i1 %13, label %14, label %23

14:                                               ; preds = %10
  %15 = load i32, ptr %3, align 4
  store i32 %15, ptr %5, align 4
  %16 = load i32, ptr %2, align 4
  %17 = load i32, ptr %3, align 4
  %18 = add nsw i32 %16, %17
  store i32 %18, ptr %3, align 4
  %19 = load i32, ptr %3, align 4
  call void @putint(i32 %19)
  call void @putch(i32 10)
  %20 = load i32, ptr %5, align 4
  store i32 %20, ptr %2, align 4
  %21 = load i32, ptr %4, align 4
  %22 = add nsw i32 %21, 1
  store i32 %22, ptr %4, align 4
  br label %10, !llvm.loop !6

23:                                               ; preds = %10
  ret i32 0
}



attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 15.0.7"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}

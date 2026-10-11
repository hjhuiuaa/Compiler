; ModuleID = 'ir/features-riscv.ll'
source_filename = "features.sy"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "riscv64-unknown-linux-gnu"

@calls = global i32 0, align 4

declare i32 @getint()

declare void @putint(i32)

declare void @putch(i32)

define i32 @touch(i32 %x) {
entry:
  %old = load i32, ptr @calls, align 4
  %next = add nsw i32 %old, 1
  store i32 %next, ptr @calls, align 4
  ret i32 %x
}

define i32 @reduce(ptr %a, i32 %n) {
entry:
  br label %cond

cond:                                             ; preds = %step, %entry
  %i = phi i32 [ 0, %entry ], [ %next, %step ]
  %sum = phi i32 [ 0, %entry ], [ %newsum, %step ]
  %more = icmp slt i32 %i, %n
  br i1 %more, label %body, label %exit

body:                                             ; preds = %cond
  %idx = sext i32 %i to i64
  %p = getelementptr i32, ptr %a, i64 %idx
  %v = load i32, ptr %p, align 4
  %zero = icmp eq i32 %v, 0
  br i1 %zero, label %exit, label %check

check:                                            ; preds = %body
  %neg = icmp slt i32 %v, 0
  br i1 %neg, label %skip, label %add

skip:                                             ; preds = %check
  br label %step

add:                                              ; preds = %check
  %s = add nsw i32 %sum, %v
  br label %step

step:                                             ; preds = %add, %skip
  %newsum = phi i32 [ %sum, %skip ], [ %s, %add ]
  %next = add nsw i32 %i, 1
  br label %cond

exit:                                             ; preds = %body, %cond
  ret i32 %sum
}

define i32 @blend(float %x, float %y) {
entry:
  %a = fadd float %x, 5.000000e-01
  %b = fmul float %a, 2.000000e+00
  %c = fsub float %b, %y
  %d = fdiv float %c, 2.000000e+00
  %r = fptosi float %d to i32
  ret i32 %r
}

define void @emit(i32 %x) {
entry:
  call void @putint(i32 %x)
  call void @putch(i32 10)
  ret void
}

define i32 @main() {
entry:
  %x = call i32 @getint()
  %d = call i32 @getint()
  %a = alloca [5 x i32], align 4
  %p1 = getelementptr [5 x i32], ptr %a, i64 0, i64 1
  %p2 = getelementptr [5 x i32], ptr %a, i64 0, i64 2
  %p3 = getelementptr [5 x i32], ptr %a, i64 0, i64 3
  %p4 = getelementptr [5 x i32], ptr %a, i64 0, i64 4
  store i32 %x, ptr %a, align 4
  store i32 -2, ptr %p1, align 4
  store i32 %d, ptr %p2, align 4
  store i32 0, ptr %p3, align 4
  store i32 9, ptr %p4, align 4
  %sum = add nsw i32 %x, %d
  call void @emit(i32 %sum)
  %diff = sub nsw i32 %x, %d
  call void @emit(i32 %diff)
  %prod = mul nsw i32 %x, %d
  call void @emit(i32 %prod)
  %nonzero = icmp ne i32 %d, 0
  br i1 %nonzero, label %divide, label %zero

divide:                                           ; preds = %entry
  %q = sdiv i32 %x, %d
  %r = srem i32 %x, %d
  call void @emit(i32 %q)
  call void @emit(i32 %r)
  br label %classify

zero:                                             ; preds = %entry
  call void @emit(i32 0)
  call void @emit(i32 0)
  br label %classify

classify:                                         ; preds = %zero, %divide
  %negative = icmp slt i32 %x, 0
  br i1 %negative, label %neg, label %nonneg

neg:                                              ; preds = %classify
  call void @emit(i32 -1)
  br label %and.left

nonneg:                                           ; preds = %classify
  %iszero = icmp eq i32 %x, 0
  br i1 %iszero, label %eq, label %pos

eq:                                               ; preds = %nonneg
  call void @emit(i32 0)
  br label %and.left

pos:                                              ; preds = %nonneg
  call void @emit(i32 1)
  br label %and.left

and.left:                                         ; preds = %pos, %eq, %neg
  br i1 %nonzero, label %and.right, label %and.false

and.right:                                        ; preds = %and.left
  %q2 = sdiv i32 %x, %d
  %gt = icmp sgt i32 %q2, 1
  br i1 %gt, label %and.true, label %and.false

and.true:                                         ; preds = %and.right
  br label %and.end

and.false:                                        ; preds = %and.right, %and.left
  br label %and.end

and.end:                                          ; preds = %and.false, %and.true
  %and.value = phi i32 [ 1, %and.true ], [ 0, %and.false ]
  call void @emit(i32 %and.value)
  br i1 %nonzero, label %or.right, label %or.true

or.right:                                         ; preds = %and.end
  %touched = call i32 @touch(i32 %x)
  %truth = icmp ne i32 %touched, 0
  br i1 %truth, label %or.true, label %or.false

or.true:                                          ; preds = %or.right, %and.end
  br label %or.end

or.false:                                         ; preds = %or.right
  br label %or.end

or.end:                                           ; preds = %or.false, %or.true
  %or.value = phi i32 [ 1, %or.true ], [ 0, %or.false ]
  call void @emit(i32 %or.value)
  %count = load i32, ptr @calls, align 4
  call void @emit(i32 %count)
  %le = icmp sle i32 %x, %d
  %not = xor i1 %le, true
  br i1 %not, label %not.right, label %not.false

not.right:                                        ; preds = %or.end
  %ge = icmp sge i32 %x, 0
  br i1 %ge, label %not.true, label %not.false

not.true:                                         ; preds = %not.right
  br label %not.end

not.false:                                        ; preds = %not.right, %or.end
  br label %not.end

not.end:                                          ; preds = %not.false, %not.true
  %not.value = phi i32 [ 1, %not.true ], [ 0, %not.false ]
  call void @emit(i32 %not.value)
  %total = call i32 @reduce(ptr %a, i32 5)
  call void @emit(i32 %total)
  %xf = sitofp i32 %x to float
  %df = sitofp i32 %d to float
  %mixed = call i32 @blend(float %xf, float %df)
  call void @emit(i32 %mixed)
  %minus.x = sub nsw i32 0, %x
  call void @emit(i32 %minus.x)
  %inner.x = add nsw i32 %d, 1
  call void @emit(i32 %inner.x)
  call void @emit(i32 %x)
  ret i32 0
}

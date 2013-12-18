
define i32  @calcul(i32 %x) {
	%f = mul i32 %x, %x
	%a = sub i32 %f, 10
	ret i32 %a 

}

@str = constant [7 x i8 ] c"=> %d\0A\00"
declare i32 @printf ( i8 * , ...)


define i32 @main () {
%x = call i32 @calcul( i32 32)
call i32 ( i8 * , ...) * @printf ( i8 * getelementptr ([7 x i8] * @str , i32 0, i32 0), i32 %x)
ret i32 0
}

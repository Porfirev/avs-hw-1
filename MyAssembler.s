# Команды для компиляции, компоновки и запуска в gdb
# as --gstabs -o MyAssembler.o MyAssembler.s
# gcc MyAssembler.o -o MyAssembler
# ./MyAssembler
#------------------------------------------------
# "MyAssembler.s"
# Использование подпрограмм для демонстрации разделения по функциям
    .intel_syntax noprefix

    .equ    max_size, 1000000 # можно менять 
    .equ    int_size, 4

    .section .rodata
gg_string:
    .string      "Вы всё сломали!!!\n"
format_in:
    .string      "%d"
format_in_n:
    .string      "%u"
in_print_n:
    .string      "n? "
in_print_ai:
    .string      "A[%d] "
format_out:
	.string		 "%d "
format_out_last:
	.string		 "\n"

    #.section .bss
    .section .data
A:
    .space max_size*int_size
B:
	.space max_size*int_size    
n:
    .long   0
b_len:
	.long	0
i:
    .long   0
first_pos:
	.long 	-1
last_neg:
	.long	-1
		
#------------------------------------------------
# Подпрограмма ввода элементов массива
    .section .text
    #.global array_input --- пока функции сделаны статическими (внутренними)
array_input:      # ввод массива с консоли
    push    rbp
    mov     rbp, rsp

    # Приглашение для ввода значения длины
    lea     rdi, in_print_n[rip]
    mov     rsi, max_size
    mov     eax, 0
    call    printf@PLT

   # Ввод длины в заданном диапазоне
    lea     rdi, format_in_n[rip]   # формат вывода
    lea     rsi, n[rip]        		#  адрес для ввода
    mov     eax, 0                  # ввод целых чисел
    call    scanf@PLT
    
    mov		edx, n[rip]
    or		edx, edx
    js		gg
    

ok:         # Цикл ввода элементов массива
    mov     dword ptr i[rip], 0     # i: обнуление
loop_scan:
    mov     ecx, i[rip]             # временное использование
    cmp     ecx, n[rip]        		# проверка на окончание
    jge     end_loop_scan           # завершение ввода элементов
    push    rcx                     # сохранение текущего i
    push    rbx                     # сохранение адреса массива
    lea     rdi, in_print_ai[rip]   # приглашение к вводу
    mov     esi, ecx                #  индекс элемента массива
    mov     eax, 0
    call    printf@PLT
    mov     ecx, i[rip]             # i: восстановление после printf
    shl     ecx, 2                  # получение сдвига от значения i
    lea     rbx, A[rip]             # адрес начала массива
    lea     rdi, format_in[rip]     # формат вывода
    lea     rsi, A[rip]             # адрес для ввода
    add     rsi, rcx
    mov     eax, 0                  # ввод целых чисел
    call    scanf@PLT
    pop     rbx                     # адреса массива
    pop     rcx                     # восстановление i
    inc     dword ptr i[rip]        # ++i
    jmp     loop_scan
end_loop_scan:
    mov	rax, 0                      # it's OK
    pop rbp
    ret

gg:
    mov rax, 1
    pop	rbp
    ret

#------------------------------------------------
# Подпрограмма вывода элементов массива
    .section .text
    #.global array_output --- пока функции сделаны статическими (внутренними)
array_output:      # вывод массива на дисплей
    push    rbp
    mov     rbp, rsp

    # Вывод массива
    mov     dword ptr i[rip], 0
loop_print:
    mov     ecx, i[rip]
    mov     edx, b_len[rip]
    lea     rbx, B[rip]
    cmp     ecx, edx
    jge     end_loop_print
    lea     rdi, format_out[rip]    # формат вывода
    mov     esi, i[rip]             # индекс числа
    mov     rsi, [rcx*int_size+rbx] # выводимое число
    mov     eax, 0                  # вывод целых чисел
    call    printf@PLT
    inc     dword ptr i[rip]
    jmp     loop_print
end_loop_print:
	
	lea 	rdi, format_out_last[rip] 
	call 	printf@PLT			    # перевод строки
    mov	rax, 0                      # it's OK
    pop	rbp
    ret
    
#------------------------------------------------
# Подсчёт индекса первого положительного
count_first_pos:
	push    rbp
        mov     rbp, rsp
	
	# Сам подсчёт
	mov     r11, 0
	mov     r12, n[rip]
	lea     r13, A[rip]
loop_count_pos:
    cmp     r11, r12
    jge     end_loop_count_pos
	mov		eax, dword ptr [r11*int_size+r13]
	or		eax, eax
	js		not_if_pos					# когда стало отрицательным
	cmp		eax, 0
	je		not_if_pos					# 0 - тоже не положительное
	mov		first_pos[rip], r11
	jmp		end_loop_count_pos						    
not_if_pos:
	inc		r11
	jmp		loop_count_pos				# Выходим когда закончили
	
end_loop_count_pos:
	mov rax, 0
    pop	rbp
    ret

#------------------------------------------------
# Подсчёт индекса последнего отрицательного
count_last_neg:
	push    rbp
    mov     rbp, rsp
	
	# Сам подсчёт
	mov		r11, n[rip]
    dec     r11
loop_count_neg:
    or     	r11, r11
    js     	end_loop_count_neg			# когда стало отрицательным
    lea     r12, A[rip]
	mov		eax, dword ptr [r11*int_size+r12]
	or		eax, eax
	jns		not_if_neg					# Здесь мы как раз выйдем если не отрицательное (0 - уже подходит)
	mov		last_neg[rip], r11                    
    jmp		end_loop_count_neg			# Выходим когда закончили				    
not_if_neg:
	dec		r11
	jmp		loop_count_neg
	
end_loop_count_neg:
	mov rax, 0
    pop	rbp
    ret

#------------------------------------------------
# Перёнос A в B
move:
	push    rbp
    mov     rbp, rsp
	
	# Сам переносы
	mov		r11, 0 # Индекс A
	mov		r12, 0 # Индекс B
	mov		r13, n[rip] # n
	mov		edx, dword ptr first_pos[rip] # Индекс первого положительного
	mov		r15, last_neg[rip] # Индекс последнего отрицательного
	lea     rcx, A[rip] # Указатель на массив A
	lea		rbx, B[rip] # Указатель на массив B
loop_move:
    cmp     r11, r13
    jge     end_loop_mov						# когда стало отрицательным
    cmp 	r11, rdx							# Если это первое положительное
    je		no_add
    cmp		r11, r15 							# Если это последние отрицательное
    je		no_add
	mov		eax, dword ptr [r11*int_size+rcx]
	mov		dword ptr [r12*int_size+rbx], eax
	inc		r12				    
no_add:
	inc		r11
	jmp		loop_move
	
end_loop_mov:
	mov b_len[rip], r12 
	mov rax, 0
    pop	rbp
    ret
        
#------------------------------------------------
# Главная функция программы
    .section .text
    .global main
main:
    push    rbp
    mov     rbp, rsp

    # Вызов подпрограммы ввода элементов массива
    call    array_input
    
    mov		r11, 0
    cmp		rax, r11
    jg		gg_all
    
    call	   count_first_pos				

    call	   count_last_neg

	call    move   
	
    call    array_output

    
end:
    mov	rax, 0
    mov     rsp, rbp            # удалить локальные переменные
    pop     rbp                 # восстановить кадр вызывающего
    ret
    
gg_all:
	lea	rdi, gg_string[rip]
	call	printf@PLT
	pop rbp
	ret
	

.data
    m1: .space 4
    m2: .space 4
    mres: .space 4
    nrleg: .space 400
    p: .space 4
    n: .space 4
    lung: .space 4
    x: .space 4
    y: .space 4
    nr: .space 4
    i: .space 4
    j: .space 4
    k: .space 4
    n1: .space 4
    formatScanf: .asciz "%ld"
    formatPrintf: .asciz "%ld "
    newLine: .asciz "\n"
    formatPrintf2: .asciz "%ld"

.text

matrix_mult:
    pushl %ebp
    mov %esp, %ebp

    pushl %esp
    pushl %ebx
    pushl %esi
    pushl %edi

    subl $4, %esp
    movl $0, -20(%ebp)
    jmp et_for_lin_mult
    
    et_for_lin_mult:
        movl -20(%ebp), %ecx
        cmp %ecx, 20(%ebp)
        je et_sf_matrix_mult

        subl $4, %esp
        movl $0, -24(%ebp)
        jmp et_for_col_mult

        et_for_col_mult:
            movl -24(%ebp), %ecx
            cmp %ecx, 20(%ebp)
            je et_sf_col_mult

            movl -20(%ebp), %eax
            movl $0, %edx
            mull 20(%ebp)
            addl -24(%ebp), %eax

            movl 16(%ebp), %esi
            lea 0(%esi), %edi
            movl $0, (%edi, %eax, 4)

            subl $4, %esp
            movl $0, -28(%ebp)
            jmp et_for_elem_mult

            et_for_elem_mult:
                movl -28(%ebp), %ecx
                cmp %ecx, 20(%ebp)
                je et_sf_elem_mult

                ;//accesam elementul din prima matrice
                movl -20(%ebp), %eax
                movl $0, %edx
                mull 20(%ebp)
                addl -28(%ebp), %eax

                movl 8(%ebp), %esi
                lea 0(%esi), %edi
                movl (%edi, %eax, 4), %ecx

                ;//accesam elementul din a doua matrice
                movl -28(%ebp), %eax
                movl $0, %edx
                mull 20(%ebp)
                addl -24(%ebp), %eax

                movl 12(%ebp), %esi
                lea 0(%esi), %edi
                movl (%edi, %eax, 4), %ebx

                ;//calculam rezultatul
                movl %ecx, %eax
                movl $0, %edx
                mull %ebx
                movl %eax, %ecx

                ;//accesam elementul din matricea resultanta
                movl -20(%ebp), %eax
                movl $0, %edx
                mull 20(%ebp)
                addl -24(%ebp), %eax

                movl 16(%ebp), %esi
                lea 0(%esi), %edi
                movl (%edi, %eax, 4), %ebx
                addl %ebx, %ecx
                movl %ecx, (%esi, %eax, 4)

                incl -28(%ebp)
                jmp et_for_elem_mult

            et_sf_elem_mult:
                addl $4, %esp
                incl -24(%ebp)
                jmp et_for_col_mult
        
        et_sf_col_mult:
            addl $4, %esp
            incl -20(%ebp)
            jmp et_for_lin_mult

    et_sf_matrix_mult:
        addl $4, %esp
        popl %edi
        popl %esi
        popl %ebx
        popl %esp
        popl %ebp
        ret

.globl main

;//citerea lui p si n
main:
    movl $192, %eax ;// adresa de apel a functiei
    movl $0, %ebx ;// adresa null
    movl $120000, %ecx ;// dimensiunea celor 3 matrici folosite, fiind de 100 pe 100 cu elemente long
    movl $0x2, %edx ;// PROT_WRITE, sa putem scrie in memorie
    movl $0x22, %esi ;// MAP_ANONYMOUS si MAP_PRIVATE, ca sa nu trebuiasca folosit un fisier pentru memorie, iar aceasta sa nu poata fi accesata din afara programului
    movl $0xffffffff, %edi ;// file descriptorul e -1, intru-cat avem MAP_ANONYMOUS, care nu foloseste niciun fisier
    movl $0, %ebp ;// offset-ul e 0 deoarece nu folosim niciun fisier
    int $0x80

    movl %eax, m1 ;// retinem adresa primei matrici
    
    lea 40000(%eax), %edi ;// retinem adresa celei de a doua matrici
    movl %edi, m2

    lea 80000(%eax), %edi ;// retinem adresa atricii rezultante
    movl %edi, mres

    pushl $p
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx

    pushl $n
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx

    movl $0, i
    jmp et_for_nrleg

;//citirea nr de legaturi pentru fiecare nod
et_for_nrleg:
    movl i, %ecx
    cmp n, %ecx
    je et_prep_for_mat

    pushl $nr
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx

    movl nr, %ebx
    movl i, %ecx
    lea nrleg, %edi
    movl %ebx, (%edi, %ecx, 4)

    incl i
    jmp et_for_nrleg

;//citirea lungimii drumului, precum si a celor 2 noduri
et_cit_p2:
    pushl $lung
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx

    pushl $x
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx

    pushl $y
    pushl $formatScanf
    call scanf
    popl %ebx
    popl %ebx

    jmp et_cop_m1_m2

;//citirea listelor de adiacenta si formarea matricii de adiacenta
et_prep_for_mat:
    movl $0, i
    jmp et_for_mat

et_for_mat:
    movl i, %ecx
    cmp n, %ecx
    je et_if_cerinte

    movl i, %ecx
    lea nrleg, %esi
    movl (%esi, %ecx, 4), %ebx
    movl %ebx, n1
    movl $0, j

    for_nod:
        movl j, %ecx
        cmp n1, %ecx
        je sf_nod

        pushl $nr
        pushl $formatScanf
        call scanf
        popl %ebx
        popl %ebx

        movl i, %eax
        movl $0, %edx
        mull n
        addl nr, %eax
        movl m1, %edi
        movl $1, (%edi, %eax, 4)

        incl j
        jmp for_nod

    sf_nod:
        incl i
        jmp et_for_mat

;//if pentru care cerinta trebuie rezolvata
et_if_cerinte:
    movl p, %eax
    movl $1, %ebx
    cmp %eax, %ebx
    je et_afis_mat

    jmp et_cit_p2

;//afisarea matricii pentru cerinta 1
et_afis_mat:
    movl $0, i
    jmp for_afis_lin

    for_afis_lin:
        movl i, %ecx
        cmp n, %ecx
        je et_exit

        movl $0, j

        for_afis_col:
            movl j, %ecx
            cmp n, %ecx
            je sf_afis_col

            movl i, %eax
            movl $0, %edx
            mull n
            addl j, %eax

            movl m1, %esi
            movl (%esi, %eax, 4), %ebx
            pushl %ebx
            pushl $formatPrintf
            call printf
            popl %ebx
            popl %ebx

            pushl $0
            call fflush
            popl %ebx

            incl j
            jmp for_afis_col

    sf_afis_col:
        ;//movl $4, %eax
        ;//movl $1, %ebx
        ;//mov $newLine, %ecx
        ;//movl $2, %edx
        ;//int $0x80

        pushl $newLine
        call printf
        popl %ebx

        pushl $0
        call fflush
        popl %ebx

        incl i
        jmp for_afis_lin

;//copierea matricii 1 in 2
et_cop_m1_m2:
    movl $0, i
    jmp for_cop_lin1

    for_cop_lin1:
        movl i, %ecx
        cmp n, %ecx
        je et_p2

        movl $0, j

        for_cop_col1:
            movl j, %ecx
            cmp n, %ecx
            je sf_cop_col1

            movl i, %eax
            movl $0, %edx
            mull n
            addl j, %eax

            movl m1, %esi
            movl (%esi, %eax, 4), %ebx
            movl m2, %edi
            movl %ebx, (%edi, %eax, 4)

            incl j
            jmp for_cop_col1

    sf_cop_col1:
        incl i
        jmp for_cop_lin1

;//inceputul cerintei 2
et_p2:
    movl $1, k
    jmp et_for_p2

;//for pentru inmultirea matricelor de k-1 ori
et_for_p2:
    movl k, %ecx
    cmp %ecx, lung
    je et_afis_p2
    
    pushl n
    pushl mres
    pushl m2
    pushl m1
    call matrix_mult
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx

    jmp et_cop_mres_m2

;//copierea matricii rezultante in matricea 2
et_cop_mres_m2:
    movl $0, i
    jmp for_cop_lin2

    for_cop_lin2:
        movl i, %ecx
        cmp n, %ecx
        je et_cont_p2

        movl $0, j

        for_cop_col2:
            movl j, %ecx
            cmp n, %ecx
            je sf_cop_col2

            movl i, %eax
            movl $0, %edx
            mull n
            addl j, %eax

            movl mres, %esi
            movl (%esi, %eax, 4), %ebx
            movl m2, %edi
            movl %ebx, (%edi, %eax, 4)

            incl j
            jmp for_cop_col2

    sf_cop_col2:
        incl i
        jmp for_cop_lin2

et_cont_p2:
    incl k
    jmp et_for_p2

;//afisarea cerintei 2
et_afis_p2:
    movl m2, %esi
    movl x, %eax
    movl $0, %edx
    mull n
    addl y, %eax
    movl (%esi, %eax, 4), %ebx

    pushl %ebx
    pushl $formatPrintf2
    call printf
    popl %ebx
    popl %ebx

    pushl $0
    call fflush
    popl %ebx
    
    pushl $newLine
    call printf
    popl %ebx

    pushl $0
    call fflush
    popl %ebx

    jmp et_exit

;//sfarsitul programului
et_exit:
    movl $91, %eax ;// folosim munmap sa dealocam memoria
    movl m1, %ebx ;// adresa memoriei
    int $0x80

    movl $1, %eax
    xor %ebx, %ebx
    int $0x80

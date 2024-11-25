.data
slist: .word 0          # Puntero a la lista de categorías.
cclist: .word 0         # Puntero a la categoría actual.
wclist: .word 0         # Puntero a una categoría auxiliar (por ejemplo, para eliminar o iterar).
schedv: .space 32       # Espacio reservado para datos temporales.
menu: .ascii "\nColecciones de objetos categorizados\n"
      .ascii "====================================\n"
      .ascii "1-Nueva categoria\n"
      .ascii "2-Siguiente categoria\n"
      .ascii "3-Categoria anterior\n"
      .ascii "4-Listar categorias\n"
      .ascii "5-Borrar categoria actual\n"
      .ascii "6-Anexar objeto a la categoria actual\n"
      .ascii "7-Listar objetos de la categoria\n"
      .ascii "8-Borrar objeto de la categoria\n"
      .ascii "0-Salir\n"
      .asciiz "Ingrese la opcion deseada: "  # Texto del menú principal.

opcion1: .asciiz "\n-Agregar una nueva categoria\n"  
opcion2: .asciiz "\n- Siguiente categoria\n"        
opcion3: .asciiz "\n- Categoria anterior\n"         
opcion4: .asciiz "\n- Listar categorias\n"          
opcion5: .asciiz "\n- Borrar categoria actual\n"    
opcion6: .asciiz "\n- Anexar objetos a la categoria actual\n" 
opcion7: .asciiz "\n-Listar objetos de las categorias\n"      
opcion8: .asciiz "\n- Borrar objeto de la categoria\n"       

msjCatSig: .asciiz "Has pasado a la siguiente categoria"  
msjCatAnt: .asciiz "Has pasado a la anterior categoria"   
msjError201: .asciiz "\nError201:No hay categorias"       
msjError202: .asciiz "\nError202:Solo hay una categoria"  
msjError301: .asciiz "\nError301:No existen categorias"   

error: .asciiz "\nError: "          
return: .asciiz "\n"                
catName: .asciiz "\nIngrese el nombre de una categoria: "  
selCat: .asciiz "\nSe ha seleccionado la categoria:"      
idObj: .asciiz "\nIngrese el ID del objeto a eliminar: "   
objName: .asciiz "\nIngrese el nombre de un objeto: "      
success: .asciiz "La operación se realizo con exito\n\n"   


.text
main:

# Bucle principal del programa
loop:
    jal mostrarMenu # Llama a la función que muestra el menú y pide que se ingrese una opción
    beq $v0, 1, opcion1_menu # En base a la opción elegida por el usuario, salta a la etiqueta correspondiente
    beq $v0, 2, opcion2_menu
    beq $v0, 3, opcion3_menu
    beq $v0, 4, opcion4_menu
    beq $v0, 5, opcion5_menu
    beq $v0, 6, opcion6_menu
    beq $v0, 7, opcion7_menu
    beq $v0, 8, opcion8_menu
    beqz $v0, exit # Si elige 0, salir del programa
    # Si elige una opción fuera de las dadas, muestra un mensaje de error
    la $a0, error
    li $v0, 4
    syscall
    j mostrarMenu

# Función para mostrar el menú
mostrarMenu:
    la $a0, menu
    li $v0, 4
    syscall # Muestra el menú
    li $v0, 5
    syscall # Pide al usuario que ingrese una opción
    jr $ra # Retorna a donde se llamó la función

# Funciones para manejar las opciones del menú

# Opción 1: Agregar nueva categoría
opcion1_menu:
    la $a0, opcion1
    li $v0, 4
    syscall
    jal newcaterogy
    j loop

# Opción 2: Siguiente categoría
opcion2_menu:
    la $a0, opcion2
    li $v0, 4
    syscall
    jal sigCat
    j loop

# Opción 3: Categoría anterior
opcion3_menu:
    la $a0, opcion3
    li $v0, 4
    syscall
    jal categoriaAnterior
    j loop

# Opción 4: Listar categorías
opcion4_menu:
    la $a0, opcion4
    li $v0, 4
    syscall
    jal listarCategorias
    j loop

# Opción 5: Borrar categoría actual
opcion5_menu:
    la $a0, opcion5
    li $v0, 4
    syscall
    jal main
    j loop

# Opción 6: Anexar objeto a la categoría actual
opcion6_menu:
    la $a0, opcion6
    li $v0, 4
    syscall
    jal anexarObjeto
    j loop

# Opción 7: Listar objetos de la categoría
opcion7_menu:
    la $a0, opcion7
    li $v0, 4
    syscall
    jal listarObjetosCategoria
    j loop

# Opción 8: Borrar objeto de la categoría
opcion8_menu:
    la $a0, opcion8
    li $v0, 4
    syscall
    jal main
    j loop

# Función para pasar a la siguiente categoría
sigCat:
    lw $t0, cclist          # Carga en $t0 la dirección de la categoría actual desde cclist
    beqz $t0, error_201      # Si cclist es nulo (no apunta a ninguna categoría), salta a error_201

    lw $t1, 12($t0)          # Carga en $t1 el puntero a la siguiente categoría desde $t0+12
    beq $t0, $t1, error_202  # Si la categoría actual apunta a sí misma, salta a error_202 (error)

    la $a0, msjCatSig        # Carga la dirección del mensaje "Siguiente categoría:" en $a0
    li $v0, 4                # Servicio de impresión de cadenas (syscall 4)
    syscall                  # Imprime el mensaje en la consola

    lw $a0, cclist           # Carga en $a0 la dirección de la categoría actual (cclist)
    lw $a0, 4($a0)           # Avanza 4 bytes: obtiene un puntero a información adicional
    lw $a0, 0($a0)           # Obtiene la información (probablemente el nombre de la categoría)
    li $v0, 4                # Servicio de impresión de cadenas (syscall 4)
    syscall                  # Imprime el nombre o descripción de la categoría

    j exit_sigCat            # Salta a la etiqueta exit_sigCat para terminar la rutina


error_201:
    la $a0, msjError201
    li $v0, 4
    syscall
    j exit_sigCat

error_202:
    la $a0, msjError202
    li $v0, 4
    syscall
    j exit_sigCat

exit_sigCat:
    j loop

# Función para pasar a la categoría anterior
categoriaAnterior:
    # Verificar si no hay categorías (error 201)
    lw $t0, cclist
    beqz $t0, error_201_ca

    # Verificar si hay solo una categoría (error 202)
    lw $t1, 0($t0) # Categoría anterior
    beq $t0, $t1, error_202_ca

    # Mostrar mensaje de éxito y retroceder a la categoría anterior
    la $a0, msjCatAnt
    li $v0, 4
    syscall

    # Actualizar el puntero a la categoría anterior
    lw $t0, cclist
    lw $t0, 0($t0)  # Dirección de la categoría anterior
    sw $t0, cclist

    # Mostrar mensaje de la categoría seleccionada
    lw $a0, 4($t0)  # Dirección del nombre de la categoría
    lw $a0, 0($a0)  # Contenido de la dirección
    li $v0, 4
    syscall

    j exit_categoriaAnterior

error_201_ca:
    # Mostrar mensaje de error 201 y volver al menú
    la $a0, msjError201
    li $v0, 4
    syscall
    j exit_categoriaAnterior

error_202_ca:
    # Mostrar mensaje de error 202 y volver al menú
    la $a0, msjError202
    li $v0, 4
    syscall
    j exit_categoriaAnterior

exit_categoriaAnterior:
    j loop

# Función para anexar un objeto a la categoría actual
anexarObjeto:
    la $a0, cclist      # Cargar la lista de categorías
    jal obtenerCategoria # Obtener la categoría actual
    move $t0, $v0        # Guardar la dirección de la categoría

    la $a0, objName      # Cargar el nombre del objeto
    jal getblock         # Reservar memoria para el nombre del objeto
    move $t1, $v0        # Guardar la dirección del nombre del objeto

    sw $t1, 8($t0)       # Guardar la dirección del objeto en la categoría
    la $a0, success      # Mensaje de éxito
    li $v0, 4
    syscall
    j loop

obtenerCategoria:
    lw $v0, cclist      # Obtener la categoría actual
    jr $ra

# Función para listar los objetos de la categoría actual
listarObjetosCategoria:
    # Verificar si no hay categorías (error 301)
    lw $t0, cclist
    beqz $t0, error_301_obj

    # Obtener la lista de objetos de la categoría actual
    lw $t1, 8($t0)  # Dirección de la lista de objetos

    # Verificar si no hay objetos (error 401)
    beqz $t1, error_401_obj

    # Recorrer y mostrar los objetos de la lista
mostrarObjetos:
    # Mostrar el nombre del objeto actual
    lw $a0, 0($t1)  # Dirección del nombre del objeto
    li $v0, 4
    syscall

    # Mostrar un salto de línea
    la $a0, return
    li $v0, 4
    syscall

    # Mover al siguiente nodo
    lw $t1, 12($t1)  # Dirección del siguiente nodo
    bnez $t1, mostrarObjetos

    j exit_listarObjetosCategoria

error_401_obj:
    # Mostrar mensaje de error 401 y volver al menú
    la $a0, msjError301  # Puedes definir un mensaje de error específico si prefieres
    li $v0, 4
    syscall
    j exit_listarObjetosCategoria

error_301_obj:
    # Mostrar mensaje de error 301 y volver al menú
    la $a0, msjError301
    li $v0, 4
    syscall
    j exit_listarObjetosCategoria

exit_listarObjetosCategoria:
    j loop

# Función para listar las categorías
listarCategorias:
    # Verificar si no hay categorías (error 301)
    lw $t0, cclist
    beqz $t0, error_301_lc

    la $a0, catName
    jal cleanBuffer
    li $v0, 4
    syscall

    # Mostrar mensaje de éxito y lista de categorías
    la $a0, success
    li $v0, 4
    syscall

    lw $t0, cclist
    lw $t1, 4($t0) # Dirección del primer nodo

print_categories:
    # Mostrar el nombre de la categoría actual
    lw $a0, 0($t1) # Contenido de la dirección (nombre de la categoría)
    li $v0, 4
    syscall

    # Mostrar un salto de línea
    li $v0, 4
    la $a0, return
    syscall

    # Mover al siguiente nodo
    lw $t1, 12($t1) # Dirección del siguiente nodo
    bnez $t1, print_categories

    j exit_listarCategorias

error_301_lc:
    # Mostrar mensaje de error 301 y volver al menú
    la $a0, msjError301
    li $v0, 4
    syscall
    j exit_listarCategorias

exit_listarCategorias:
    j loop

# Función para agregar una nueva categoría
newcaterogy:
    addiu $sp, $sp, -4
    sw $ra, 4($sp)
    la $a0, catName # Input category name
    jal getblock
    move $a2, $v0 # $a2 = *char to category name
    la $a0, cclist # $a0 = list
    li $a1, 0 # $a1 = NULL
    jal addnode
    lw $t0, wclist
    bnez $t0, newcategory_end
    sw $v0, wclist # Update working list if was NULL

newcategory_end:
    li $v0, 0 # Return success
    lw $ra, 4($sp)
    addiu $sp, $sp, 4
    jr $ra

# Función para agregar un nodo
addnode:
    addi $sp, $sp, -8
    sw $ra, 8($sp)
    sw $a0, 4($sp)
    jal smalloc
    sw $a1, 4($v0) # Set node content
    sw $zero, 8($v0) # Initialize node next pointer to NULL
    lw $a0, 4($sp)
    lw $t0, ($a0) # First node address
    beqz $t0, addnode_empty_list

addnode_to_end:
    lw $t1, ($t0) # Last node address
    # Update prev and next pointers of new node
    sw $t1, 0($v0)
    sw $t0, 12($v0)
    # Update prev and first node to new node
    sw $v0, 12($t1)
    sw $v0, 0($t0)
    j addnode_exit

addnode_empty_list:
    sw $v0, ($a0)
    sw $v0, 0($v0)
    sw $v0, 12($v0)

addnode_exit:
    lw $ra, 8($sp)
    addi $sp, $sp, 8
    jr $ra

# Función para eliminar un nodo
delnode:
    addi $sp, $sp, -8
    sw $ra, 8($sp)
    sw $a0, 4($sp)
    lw $a0, 8($a0) # Get block address
    jal sfree # Free block
    lw $a0, 4($sp) # Restore argument a0
    lw $t0, 12($a0) # Get address to next node of a0

node:
    beq $a0, $t0, delnode_point_self
    lw $t1, 0($a0) # Get address to prev node
    sw $t1, 0($t0)
    sw $t0, 12($t1)
    lw $t1, 0($a1) # Get address to first node

again:
    bne $a0, $t1, delnode_exit
    sw $t0, ($a1) # List point to next node
    j delnode_exit

delnode_point_self:
    sw $zero, ($a1) # Only one node

delnode_exit:
    jal sfree
    lw $ra, 8($sp)
    addi $sp, $sp, 8
    jr $ra

# Función para obtener un bloque de memoria
getblock:
    addi $sp, $sp, -4
    sw $ra, 4($sp)
    li $v0, 4
    syscall
    jal smalloc
    move $a0, $v0
    li $a1, 16
    li $v0, 8
    syscall
    move $v0, $a0
    lw $ra, 4($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para asignar memoria
smalloc:
    lw $t0, slist
    beqz $t0, sbrk
    move $v0, $t0
    lw $t0, 12($t0)
    sw $t0, slist
    jr $ra

sbrk:
    li $a0, 16 # Node size fixed 4 words
    li $v0, 9
    syscall # Return node address in v0
    jr $ra

# Función para liberar memoria
sfree:
    lw $t0, slist
    sw $t0, 12($a0)
    sw $a0, slist # $a0 node address in unused list
    jr $ra

# Función para limpiar el buffer
cleanBuffer:
    li $v0, 5
    syscall
    jr $ra

# Función para salir del programa
exit:
    li $v0, 10
    syscall

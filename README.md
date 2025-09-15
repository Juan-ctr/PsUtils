# PsUtils

## Colección de **scripts remotos** para PowerShell que se ejecutan directamente con:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/user1/PsUtils/main/Scripts/ListarArchivos.ps1) }"
```

### Actualmente incluye ListarArchivos, que recorre un directorio, lista los archivos y agrega al final de un archivo de salida un bloque por cada archivo con:
`=== ruta/relativa/del/archivo ===`
<contenido del archivo>

#### Modo de escritura: el script siempre agrega (append) al final del archivo de salida, sin sobrescribirlo.

## Estructura

PsUtils/
└─ Scripts/
   └─ ListarArchivos.ps1

Requisitos

    Windows PowerShell 5.1 o PowerShell 7+ (Core).

    Permisos de lectura sobre los archivos a procesar y de escritura en el destino del archivo de salida.

## Uso rápido:
- Ejecutar todos los archivos desde el directorio actual → files.txt (append)
```powershell
iex "& { $(irm https://raw.githubusercontent.com/user1/PsUtils/main/Scripts/ListarArchivos.ps1) }"
```

- Filtrar por extensiones (ej. ps1 y ts) y escribir en contenido.txt
```powershell
iex "& { $(irm https://raw.githubusercontent.com/user1/PsUtils/main/Scripts/ListarArchivos.ps1) } -Extensions ps1,ts -Output 'contenido.txt'"
```

- Cambiar la raíz de recorrido (ej. .\backend\src\modules) y solo json
```powershell
iex "& { $(irm https://raw.githubusercontent.com/user1/PsUtils/main/Scripts/ListarArchivos.ps1) } -Root '.\backend\src\modules' -Extensions json"
```

- Especificar una ruta absoluta para la salida
```powershell
iex "& { $(irm https://raw.githubusercontent.com/user1/PsUtils/main/Scripts/ListarArchivos.ps1) } -Output 'C:\Temp\dump.txt'"
```

- También podés usar alias de parámetros en español:
```powershell    
-Archivo / -ArchivoSalida (Output), -Ext / -Extension (Extensions), -Raiz / -Base (Root).
```

## Parámetros
Parámetro	Alias	Tipo	Default	Descripción
-Output	-Archivo, -ArchivoSalida	string	files.txt	Nombre o ruta del archivo donde se vuelca la salida. Si es relativo, se crea dentro de -Root. Se agrega al final.
-Extensions	-Ext, -Extension	string[]	(vacío)	Extensiones a incluir (con o sin punto). Si no se indica, incluye todos los archivos.
-Root	-Raiz, -Base	string	cwd	Carpeta desde la que se recorren archivos y se calculan rutas relativas.

| Parámetro     | Alias                        | Tipo       | Default     | Descripción                                                                                                             |
| ------------- | ---------------------------- | ---------- | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| `-Output`     | `-Archivo`, `-ArchivoSalida` | `string`   | `files.txt` | Nombre o ruta del archivo donde se vuelca la salida. Si es relativo, se crea dentro de `-Root`. Se **agrega** al final. |
| `-Extensions` | `-Ext`, `-Extension`         | `string[]` | *(vacío)*   | Extensiones a incluir (con o sin punto). Si no se indica, incluye **todos** los archivos.                               |
| `-Root`       | `-Raiz`, `-Base`             | `string`   | `cwd`       | Carpeta desde la que se recorren archivos y se calculan rutas **relativas**.                                            |
| `-Overwrite` |          | `switch` | *(vacío)*   | Si no se especifica, no sobreescribe el archivo, si se pone el parámetro **-Overwrite** entonces el contenido del archivo será reemplazado                               |



## Formato de salida

Cada archivo produce un bloque como:

`=== path/relativo/desde-root.ext ===`
<línea 1 del archivo>
<línea 2 del archivo>

...

    El archivo de salida se escribe en UTF-8.

    El propio archivo de salida se excluye automáticamente del recorrido para evitar auto-incluirse.

## Ejemplo de salida

    === backend/src/modules/users/service.ts ===
    import { Injectable } from '@nestjs/common';
    ...

    === backend/src/modules/users/schema.json ===
    {
    "title": "User",
    ...
    }

## Notas y buenas prácticas

    irm | iex ejecuta código remoto: usalo solo desde repositorios que confíes.

    Si querés fijar una versión exacta, reemplazá main por un commit SHA específico en la URL:

    iex "& { $(irm https://raw.githubusercontent.com/user1/PsUtils/<commit>/Scripts/ListarArchivos.ps1) }"

    Para volúmenes muy grandes de archivos, considerá ejecutar en PowerShell 7+ y excluir directorios pesados con un filtro propio previo si lo necesitás.

## Troubleshooting

    No escribe nada: verificá que haya archivos que cumplan el filtro (-Extensions) y que tengas permisos de escritura sobre -Output.

    Rutas raras en encabezados: confirmá que -Root apunte a la carpeta desde la cual querés calcular las rutas relativas.

    Caracteres extraños: el archivo de salida es UTF-8; si lo abrís con herramientas que esperan ANSI, puede verse distinto.
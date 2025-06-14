📁 Base de Datos y Archivos de Configuración
El proyecto utiliza SQL Server como sistema gestor de base de datos. Para facilitar la configuración y despliegue del entorno, se han incluido archivos descargables que contienen:

📄 Vistas

📄 Funciones

📄 Procedimientos almacenados

Estos objetos son esenciales para el correcto funcionamiento de los módulos del sistema, como la gestión de libros, usuarios, roles, autenticación y comentarios.

📥 ¿Cómo Obtener los Archivos?
Puedes acceder a los archivos SQL del proyecto de dos formas:

✅ Clonando el repositorio con Git
bash
Copiar
Editar
git clone https://github.com/usuario/repositorio.git
✅ Descargando el repositorio como archivo ZIP
Ve al repositorio en GitHub.

Haz clic en el botón verde "Code".

Selecciona "Download ZIP".

Extrae el contenido en tu equipo local.

🧩 Ejecución en SQL Server
Una vez descargados los archivos, sigue estos pasos para ejecutarlos correctamente:

Abre SQL Server Management Studio (SSMS).

Conéctate a tu instancia de SQL Server.

Abre cada archivo .sql incluido en la carpeta /Database (o su equivalente).

Ejecuta los scripts en el orden indicado (si aplica), por ejemplo:

Funciones

Vistas

Procedimientos almacenados

⚠️ Importante: Asegúrate de crear previamente la base de datos vacía sobre la que se ejecutarán estos objetos.

⚙️ Recomendaciones
Revisa la configuración de la cadena de conexión en el archivo appsettings.json para que coincida con tu servidor local de SQL Server.

Todos los objetos de base de datos están predefinidos.
No es necesario escribir consultas manualmente.

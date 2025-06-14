📁 Base de datos y archivos de configuración
El proyecto utiliza SQL Server como sistema gestor de base de datos. Para facilitar la configuración y despliegue del entorno, se han incluido archivos descargables que contienen:

Vistas

Funciones

Procedimientos almacenados

Estos objetos son esenciales para el correcto funcionamiento de los módulos del sistema, como la gestión de libros, usuarios, roles, autenticación y comentarios.

📥 ¿Cómo obtener los archivos?
Existen dos formas principales para acceder a los recursos de base de datos:

Clonando el repositorio con Git
Ejecuta el siguiente comando en tu terminal para clonar el proyecto completo:

bash
Copiar
Editar
git clone https://github.com/usuario/repositorio.git
Descargando el repositorio como archivo ZIP

Ve al repositorio en GitHub.

Haz clic en el botón verde "Code" y selecciona "Download ZIP".

Extrae el contenido en tu equipo local.

🧩 Ejecución en SQL Server
Una vez descargados los archivos:

Abre SQL Server Management Studio (SSMS).

Conéctate a tu instancia de SQL Server.

Abre cada archivo .sql incluido en la carpeta /Database o equivalente del repositorio.

Ejecuta los scripts en el orden indicado si aplica (por ejemplo: funciones → vistas → procedimientos).

✅ Importante: Asegúrate de crear previamente la base de datos vacía sobre la que se ejecutarán estos objetos.

⚙️ Recomendaciones
Es recomendable revisar la configuración de conexión a la base de datos en el archivo appsettings.json del proyecto para que coincida con tu servidor local.

Todos los objetos SQL están predefinidos. No es necesario escribir consultas manualmente.


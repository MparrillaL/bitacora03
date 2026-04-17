## Manuel Parrilla Lahoz 17/04/2026

#BITACORA III
## 1. ¿Qué es Syslog? 
Imagina que el servidor es una aplicación gigante. Syslog es el sistema estándar de mensajería que registra todo lo que pasa en el "backend" del sistema operativo [Conversación previa]. Es como el "LogCat" de Android o la consola de Chrome, pero a nivel de núcleo y servicios [1]

## 2. ¿Cómo se organiza?
Para que no sea un caos de texto, Syslog clasifica cada mensaje usando dos etiquetas que debes conocer para filtrar información con grep: [2]
	-Facility: Define el origen. Como desarrollador, te interesan las etiquetas como auth(seguridad/login), cron(tareas programadas) o daemon (proceso que se ejecuta en segundo plano sin interacción directa del usuario[3])
	-Severity: Define la prioridad de los mensajes, va desde un debug(mensajes de desarrollo) hasta emerg(¡El servidor puede explotar!) y entre medias tienes info,warning y err.[4]
	
##3. ¿Dónde lo encuentro? (El mapa FHS)
Siguiendo el estándar FHS (que organiza las estanterías de Linux), los logs están en un lugar que varía constantemente: /var/log
.
/var/log/syslog: Es el "cajón de sastre" donde va casi todo.
/var/log/auth.log: Es el diario de seguridad. Aquí ves quién ha intentado entrar por SSH a tu servidor.

##4. ¿Por qué te importa como futuro desarrollador?
Si tu aplicación web no conecta con la base de datos o el servidor Nginx no arranca, no tienes que adivinar. Usas el comando tail -f /var/log/syslog y verás en tiempo real qué error está lanzando el sistema
. Es tu herramienta principal para el Troubleshooting [5]

##5. ¿Por qué es una negligencia grave que el archivo /var/log/auth.log tenga permisos de lectura para usuarios no privilegiados?
Porque este archivo es el "diario de vida" de la seguridad del servidor, en él se registra información crítica, como cada intento de acceso, errores de contraseña y todas las sesiones iniciadas. Si un atacante con acceso limitado puede leer estos registros, podría utilizarlos para realizar ingeniería social al conocer los patrones de conexión de otros usuarios. . Además, el rastro digital permite identificar nombres de usuario válidos que el atacante puede usar para lanzar ataques de fuerza bruta dirigidos, eliminando la necesidad de adivinar cuentas existentes.

##6. ¿Qué información específica (como PIDs, nombres de usuario o direcciones IP) diferencia un intento fallido de conexión remota SSH de un simple fallo de contraseña de un usuario local frente a la pantalla?
Para diferenciarlos, debes fijarte en estos metadatos específicos:
	-Dirección IP (El rastro de red): Esta es la diferencia fundamental; un intento de conexión remota SSH registrará siempre la dirección IP de origen (por ejemplo, from 192.168.1.50). Por el contrario, un fallo de contraseña local no incluirá ninguna dirección IP, ya que la comunicación no ha viajado por la red.
 
	-Identificador de Terminal (tty): En un acceso local frente a la pantalla, el sistema vincula el rastro a una terminal física o virtual específica llamada tty (como tty1). En el rastro de SSH, verás que el evento está asociado al servicio de red sshd.
 
	-PIDs y Nombres de Usuario: Aunque ambos registros incluyen el nombre de usuario intentado y el PID (Process Identifier o identificador único del proceso que gestionó el intento), el rastro remoto de SSH suele añadir la etiqueta "invalid user" si el atacante probó un nombre que no existe en la base de datos local.
	
En resumen: La presencia de una IP es la prueba de un intento remoto, mientras que la mención de un tty sin dirección IP indica que el fallo ocurrió físicamente frente al servidor.

##7. ¿Que és el Log Management?
Para entenderlo podemos verlo como la "caja negra" de un avión. Ya sabemos que el rastro digital es fundamental para depurar errores, pero a nivel empresarial y legal, es la diferencia entre ser una víctima indefensa o un administrador con el control de la situación.[6]

8. Protección de la evidencia:
Para ejecutar la protección de la evidencia y la gestión de registros (Log Management) de forma efectiva, el proceso se resume de la siguiente manera:

###8.1 ¿Cómo se ejecuta?
	-Centralización en tiempo real: Se configuran los sistemas para enviar cada evento a un servidor externo seguro en milisegundos, impidiendo que un atacante borre el rastro si compromete la máquina local.
	
	-Configuración de Auditoría: En Windows, se activan las "Directivas de auditoría" para accesos a objetos e inicios de sesión; en Ubuntu, se utiliza auditd para vigilar archivos sensibles.
	
	-Restricción de Acceso: Se aplican permisos estrictos (PoLP) para que solo usuarios con privilegios elevados puedan leer archivos críticos como /var/log/auth.log.
	-Automatización: Se emplean scripts en Bash o herramientas como Fail2Ban para filtrar patrones de ataque (como "Failed password") y reaccionar automáticamente.
###8.2 ¿Qué conseguimos?
	-Integridad de la prueba: La evidencia permanece intacta y disponible para análisis forense incluso si el servidor de producción es destruido o manipulado.
	-Cumplimiento Legal (RGPD): Se garantiza la trazabilidad exigida por la ley en España, pudiendo demostrar quién accedió a qué datos y cuándo.
	-Vigilancia Proactiva: El sistema deja de ser una "caja negra" y permite detectar escaneos de red o intentos de fuerza bruta en tiempo real para bloquearlos antes de que tengan éxito [Conversación previa].
	-Eficiencia en el Soporte: Facilita el troubleshooting o resolución de problemas técnicos al tener un registro histórico fiable de todos los fallos del sistema


##BIBLIOGRAFÍA

[1] [DAM/DAW_SI]UD03Tema01
[2] https://www.atomix.cl/monitoreo-de-logs-con-tail-y-grep-en-linux/

[3] https://www.lenovo.com/es/es/glossary/what-is-a-daemon/?orgRef=https%253A%252F%252Fwww.google.com%252F&srsltid=AfmBOopXXsouJVP16hQAluRRWlY1Y-K920pGQeiu8ao9PPaBV0AzT0Ju

[4] https://juncotic.com/aprendiendo-syslog/
[5] https://es.linkedin.com/pulse/syslog-evolucionado-cambiando-la-forma-en-que-gestionamos-tbhbe
[6] https://www.crowdstrike.com/es-es/cybersecurity-101/next-gen-siem/log-management/

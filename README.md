# Bitácora III — Syslog y Log Management
**Manuel Parrilla Lahoz** | 17/04/2026

---

## 1. ¿Qué es Syslog?

Imagina que el servidor es una aplicación gigante. Syslog es el sistema estándar de mensajería que registra todo lo que pasa en el "backend" del sistema operativo [1]. Es como el "LogCat" de Android o la consola de Chrome, pero a nivel de núcleo y servicios [2].

---

## 2. ¿Cómo se organiza?

Para que no sea un caos de texto, Syslog clasifica cada mensaje usando dos etiquetas que debes conocer para filtrar información con `grep` [2]:

- **Facility**: Define el origen. Como desarrollador, te interesan etiquetas como `auth` (seguridad/login), `cron` (tareas programadas) o `daemon` (proceso que se ejecuta en segundo plano sin interacción directa del usuario [3]).
- **Severity**: Define la prioridad de los mensajes. Va desde `debug` (mensajes de desarrollo) hasta `emerg` (¡el servidor puede explotar!), pasando por `info`, `warning` y `err` [4].

---

## 3. ¿Dónde lo encuentro? (El mapa FHS)

Siguiendo el estándar FHS (que organiza las "estanterías" de Linux), los logs se encuentran en `/var/log`:

| Archivo | Descripción |
|---|---|
| `/var/log/syslog` | El "cajón de sastre" donde va casi todo. |
| `/var/log/auth.log` | El diario de seguridad: registra quién ha intentado entrar por SSH. |

---

## 4. ¿Por qué te importa como futuro desarrollador?

Si tu aplicación web no conecta con la base de datos o el servidor Nginx no arranca, no tienes que adivinar. Con el comando:

```bash
tail -f /var/log/syslog
```

verás en tiempo real qué error está lanzando el sistema. Es tu herramienta principal para el **troubleshooting** [5].

---

## 5. ¿Por qué es una negligencia grave que `/var/log/auth.log` tenga permisos de lectura para usuarios no privilegiados?

Porque este archivo es el "diario de vida" de la seguridad del servidor. En él se registra información crítica: cada intento de acceso, errores de contraseña y todas las sesiones iniciadas.

Si un atacante con acceso limitado puede leer estos registros, podría:

- **Realizar ingeniería social**, conociendo los patrones de conexión de otros usuarios.
- **Identificar nombres de usuario válidos** para lanzar ataques de fuerza bruta dirigidos, eliminando la necesidad de adivinar cuentas existentes.

---

## 6. ¿Qué información diferencia un intento fallido de conexión SSH de un fallo local de contraseña?

Para diferenciarlos, debes fijarte en estos metadatos específicos:

- **Dirección IP** *(el rastro de red)*: Un intento remoto SSH registrará siempre la IP de origen (e.g., `from 192.168.1.50`). Un fallo local no incluirá ninguna IP, ya que la comunicación no ha viajado por la red.

- **Identificador de Terminal (tty)**: En un acceso local, el sistema vincula el rastro a una terminal física o virtual (`tty1`). En SSH, el evento estará asociado al servicio `sshd`.

- **PIDs y nombres de usuario**: Ambos incluyen el nombre de usuario intentado y el PID del proceso. El rastro remoto SSH suele añadir la etiqueta `invalid user` si el nombre probado no existe en la base de datos local.

> **En resumen**: la presencia de una IP es la prueba de un intento remoto; la mención de un `tty` sin dirección IP indica que el fallo ocurrió físicamente frente al servidor.

---

## 7. ¿Qué es el Log Management?

Podemos entenderlo como la "caja negra" de un avión. El rastro digital es fundamental para depurar errores, pero a nivel empresarial y legal es la diferencia entre ser una víctima indefensa o un administrador con control de la situación [6].

---

## 8. Protección de la evidencia

### 8.1 ¿Cómo se ejecuta?

- **Centralización en tiempo real**: Se configuran los sistemas para enviar cada evento a un servidor externo seguro en milisegundos, impidiendo que un atacante borre el rastro si compromete la máquina local.
- **Configuración de auditoría**: En Windows se activan las *Directivas de auditoría*; en Ubuntu se utiliza `auditd` para vigilar archivos sensibles.
- **Restricción de acceso**: Se aplican permisos estrictos (PoLP) para que solo usuarios con privilegios elevados puedan leer archivos críticos como `/var/log/auth.log`.
- **Automatización**: Se emplean scripts en Bash o herramientas como **Fail2Ban** para filtrar patrones de ataque (como `Failed password`) y reaccionar automáticamente.

### 8.2 ¿Qué conseguimos?

- **Integridad de la prueba**: La evidencia permanece intacta para análisis forense incluso si el servidor de producción es destruido o manipulado.
- **Cumplimiento legal (RGPD)**: Se garantiza la trazabilidad exigida por la ley en España, pudiendo demostrar quién accedió a qué datos y cuándo.
- **Vigilancia proactiva**: El sistema permite detectar escaneos de red o intentos de fuerza bruta en tiempo real para bloquearlos antes de que tengan éxito.
- **Eficiencia en el soporte**: Facilita el troubleshooting al disponer de un registro histórico fiable de todos los fallos del sistema.

---

## Bibliografía

[1] Conversación previa  
[2] [DAM/DAW_SI] UD03Tema01  
[3] https://www.atomix.cl/monitoreo-de-logs-con-tail-y-grep-en-linux/  
[4] https://www.lenovo.com/es/es/glossary/what-is-a-daemon/  
[5] https://juncotic.com/aprendiendo-syslog/  
[6] https://es.linkedin.com/pulse/syslog-evolucionado-cambiando-la-forma-en-que-gestionamos-tbhbe  
[7] https://www.crowdstrike.com/es-es/cybersecurity-101/next-gen-siem/log-management/

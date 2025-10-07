# Política de Privacidad de Lifeline

**Fecha de vigencia:** 2 de octubre de 2025

¡Gracias por usar Lifeline! Tu privacidad es muy importante para nosotros. Esta Política de Privacidad explica qué datos recopilamos, cómo los usamos, cómo los protegemos y tus derechos respecto a tu información personal.

## 1. Información que Recopilamos

### 1.1 Información de la Cuenta
Cuando creas una cuenta, recopilamos:

- **Dirección de correo electrónico** - para identificación de cuenta y comunicación
- **Nombre para mostrar** - para personalizar tu experiencia
- **ID de usuario (UID)** - un identificador único generado por Firebase
- **Foto de perfil** (opcional) - si eliges subir una
- **País/región** (opcional) - para preferencias de localización
- **Preferencia de idioma** - para localización de la aplicación

Si inicias sesión con Google o Apple:
- Recibimos tu correo electrónico, nombre y foto de perfil de estos servicios
- No tenemos acceso a tu contraseña de cuenta de Google/Apple

### 1.2 Contenido de Recuerdos
Almacenamos el contenido que creas en Lifeline:

- **Datos de texto:** títulos, descripciones, notas de reflexión, pasos de TCC, evaluaciones emocionales
- **Archivos multimedia:** fotos, videos y notas de audio
- **Marcas de tiempo:** fechas cuando ocurrieron y se crearon los recuerdos
- **Datos musicales:** información de pistas de Spotify vinculadas (título, artista, álbum)
- **Etiquetas de ubicación** (si eliges agregarlas)
- **Datos del clima** (si se integran con tus recuerdos)
- **Etiquetas de personas** (conexiones entre recuerdos e individuos)

### 1.3 Contenido Cifrado
Si habilitas el cifrado de extremo a extremo con una contraseña maestra:

- Los campos sensibles se cifran en tu dispositivo antes de enviarse a nuestros servidores
- No podemos acceder ni leer tu contenido cifrado
- El contenido cifrado incluye campos que marcas como "privados"
- **Importante:** No podemos recuperar datos cifrados si olvidas tu contraseña maestra

### 1.4 Datos de Dispositivo y Uso
Recopilamos automáticamente:

- **Información del dispositivo:** modelo del dispositivo, versión del sistema operativo, identificadores únicos del dispositivo
- **Datos de uso de la aplicación:** funciones usadas, pantallas visitadas, métricas de rendimiento de la aplicación
- **Informes de fallos:** datos técnicos cuando la aplicación falla o encuentra errores
- **Datos analíticos:** patrones de uso anonimizados para mejorar la aplicación

Estos datos se recopilan a través de:
- Firebase Analytics
- Firebase Crashlytics
- Firebase Performance Monitoring

### 1.5 Datos Locales
Datos almacenados en tu dispositivo:

- **Base de datos Isar:** caché local de tus recuerdos para acceso sin conexión y rendimiento más rápido
- **Archivos multimedia:** fotos, videos y archivos de audio almacenados en directorios específicos de la aplicación
- **Miniaturas:** versiones comprimidas de imágenes para visualización rápida
- **Preferencias:** configuración y configuración de la aplicación

### 1.6 Datos de Notificaciones
Si habilitas las notificaciones:

- **Horarios de recordatorios:** fechas y horas para avisos de reflexión
- **Tokens de notificaciones push:** para enviar notificaciones a tu dispositivo

### 1.7 Información de Suscripción
Para suscriptores Premium:

- **Recibos de compra:** IDs de transacción de App Store o Google Play
- **Estado de suscripción:** activa, expirada o cancelada
- **Fecha de compra y fecha de renovación**

No recopilamos ni almacenamos información de tu tarjeta de pago. Todos los pagos son procesados por Apple o Google.

## 2. Cómo Usamos Tu Información

Usamos tus datos para:

### 2.1 Proporcionar el Servicio
- Almacenar y sincronizar tus recuerdos entre dispositivos
- Mostrar tu contenido en la visualización de línea de tiempo
- Procesar y comprimir archivos multimedia
- Habilitar funciones de búsqueda y organización
- Enviar recordatorios y notificaciones

### 2.2 Mejorar el Servicio
- Analizar patrones de uso de la aplicación
- Identificar y corregir errores y fallos
- Optimizar el rendimiento y los tiempos de carga
- Desarrollar nuevas funciones basadas en las necesidades de los usuarios

### 2.3 Comunicarnos Contigo
- Enviar notificaciones importantes de la cuenta
- Responder a tus solicitudes de soporte
- Notificarte de cambios en las políticas
- Proporcionar información sobre nuevas funciones (si optas por ello)

### 2.4 Garantizar la Seguridad
- Detectar y prevenir fraude o abuso
- Hacer cumplir nuestros Términos de Servicio
- Proteger contra accesos no autorizados

### 2.5 Cumplir con Obligaciones Legales
- Responder a solicitudes legales y órdenes judiciales
- Cumplir con las leyes y regulaciones aplicables

## 3. Almacenamiento y Seguridad de Datos

### 3.1 Almacenamiento en la Nube
Tus datos se almacenan en servidores de Firebase operados por Google Cloud Platform:

- **Ubicación:** Almacenamiento multi-región para confiabilidad
- **Seguridad:** Cifrado estándar de la industria en tránsito (TLS) y en reposo
- **Control de acceso:** Reglas estrictas de Firestore garantizan que solo tú puedas acceder a tus datos
- **Copias de seguridad:** Copias de seguridad automáticas para recuperación ante desastres

### 3.2 Cifrado de Extremo a Extremo
Cuando habilitas el cifrado:

- Tu contraseña maestra se usa para generar claves de cifrado
- El cifrado se realiza en tu dispositivo antes de que los datos se envíen a los servidores
- Usamos cifrado AES-256 con derivación segura de claves (PBKDF2)
- Solo tú puedes descifrar tus datos sensibles

### 3.3 Autenticación Biométrica
Si habilitas Face ID o Touch ID:

- Los datos biométricos nunca salen de tu dispositivo
- No tenemos acceso a tus huellas dactilares o datos faciales
- Los biométricos se usan solo para desbloquear la aplicación localmente

### 3.4 Medidas de Seguridad
Implementamos múltiples capas de seguridad:

- Firebase App Check para prevenir acceso no autorizado a la API
- Cifrado SSL/TLS para todas las comunicaciones de red
- Auditorías y actualizaciones de seguridad regulares
- Limitación de tasa para prevenir abusos

## 4. Compartir Datos y Servicios de Terceros

### 4.1 No Vendemos Tus Datos
Nunca venderemos, alquilaremos o comercializaremos tu información personal a terceros con fines de marketing.

### 4.2 Servicios de Terceros que Usamos

**Firebase (Google Cloud)**
- Propósito: Autenticación, base de datos, almacenamiento, análisis, informes de fallos
- Datos compartidos: Información de cuenta, contenido de recuerdos, datos de uso
- Política de privacidad: https://firebase.google.com/support/privacy

**Spotify**
- Propósito: Buscar pistas musicales para vincular a recuerdos
- Datos compartidos: Solo consultas de búsqueda (sin datos personales)
- Política de privacidad: https://www.spotify.com/privacy

**Apple App Store / Google Play**
- Propósito: Procesamiento de pagos para suscripciones Premium
- Datos compartidos: Información de compra
- Políticas de privacidad: Apple y Google

**Servicios de Procesamiento de Imágenes**
- Propósito: Comprimir imágenes y generar miniaturas
- Procesamiento: Realizado localmente en tu dispositivo
- No se comparten datos con servicios externos

### 4.3 Cuándo Podemos Compartir Datos

Podemos compartir tu información solo en estas circunstancias limitadas:

- **Con tu consentimiento:** Cuando autorizas explícitamente el intercambio
- **Requisitos legales:** Para cumplir con leyes, órdenes judiciales o procesos legales
- **Seguridad y protección:** Para proteger derechos, propiedad o seguridad de los usuarios
- **Transferencias comerciales:** En caso de fusión, adquisición o venta (con aviso para ti)

## 5. Retención de Datos

### 5.1 Cuentas Activas
Retenemos tus datos mientras tu cuenta esté activa para proporcionar el Servicio.

### 5.2 Después de la Eliminación de la Cuenta
Cuando eliminas tu cuenta:

- **Inmediato:** Tus datos se marcan para eliminación y son inaccesibles para ti
- **Dentro de 30 días:** Eliminados permanentemente de los servidores activos
- **Dentro de 90 días:** Purgados de todas las copias de seguridad
- **Análisis anonimizados:** Pueden retenerse indefinidamente para mejora del servicio

### 5.3 Retención Legal
Podemos retener ciertos datos por más tiempo si lo requiere la ley o para resolver disputas.

## 6. Tus Derechos y Opciones

### 6.1 Acceso y Exportación
Puedes:

- Ver todos tus datos dentro de la aplicación
- Exportar tus recuerdos y archivos multimedia
- Solicitar una copia de tus datos personales

### 6.2 Corrección y Actualización
Puedes actualizar tu:

- Nombre para mostrar
- Dirección de correo electrónico
- Foto de perfil
- Preferencias de idioma y país

### 6.3 Eliminación
Puedes:

- Eliminar recuerdos individuales
- Eliminar toda tu cuenta (elimina permanentemente todos los datos)
- Solicitar eliminación de datos contactándonos

### 6.4 Opciones de Exclusión
Puedes deshabilitar:

- **Notificaciones:** En la configuración de la aplicación o del dispositivo
- **Análisis:** Habilitando el cifrado (limita algunos análisis)
- **Desbloqueo biométrico:** En la configuración de seguridad de la aplicación

### 6.5 No Rastrear
Respetamos las señales de No Rastrear. Si tu navegador envía DNT, no rastrearemos tu actividad.

## 7. Privacidad de Menores

Lifeline está destinado a usuarios de 13 años o más. No recopilamos intencionalmente información personal de niños menores de 13 años. Si descubrimos que hemos recopilado datos de un niño menor de 13 años, los eliminaremos inmediatamente.

Si eres padre o tutor y crees que tu hijo nos ha proporcionado información personal, contáctanos.

## 8. Transferencias Internacionales de Datos

Tus datos pueden transferirse y almacenarse en servidores ubicados fuera de tu país de residencia. Al usar Lifeline, consientes estas transferencias. Nos aseguramos de que existan salvaguardas apropiadas para proteger tus datos.

## 9. Derechos RGPD (Para Usuarios de la UE)

Si te encuentras en la Unión Europea, tienes derechos adicionales bajo el Reglamento General de Protección de Datos (RGPD):

### 9.1 Tus Derechos
- **Derecho de acceso:** Solicitar copias de tus datos personales
- **Derecho de rectificación:** Corregir datos inexactos o incompletos
- **Derecho de supresión:** Solicitar la eliminación de tus datos ("derecho al olvido")
- **Derecho a restringir el procesamiento:** Limitar cómo usamos tus datos
- **Derecho a la portabilidad de datos:** Recibir tus datos en un formato portable
- **Derecho de oposición:** Oponerte al procesamiento de tus datos
- **Derecho a retirar el consentimiento:** Retirar el consentimiento en cualquier momento

### 9.2 Base Legal para el Procesamiento
Procesamos tus datos basándonos en:

- **Consentimiento:** Aceptas nuestras prácticas de datos
- **Contrato:** Necesario para proporcionar el Servicio
- **Intereses legítimos:** Mejorar y asegurar el Servicio

### 9.3 Oficial de Protección de Datos
Para consultas relacionadas con el RGPD, contáctanos en: founder@theplacewelive.org

## 10. Derechos CCPA (Para Usuarios de California)

Si eres residente de California, tienes derechos bajo la Ley de Privacidad del Consumidor de California (CCPA):

- **Derecho a saber:** Qué información personal recopilamos y cómo la usamos
- **Derecho a eliminar:** Solicitar la eliminación de tu información personal
- **Derecho a optar por no participar:** Optar por no vender información personal (no vendemos datos)
- **Derecho a la no discriminación:** Servicio igual independientemente de las opciones de privacidad

## 11. Incidentes de Seguridad de Datos

En caso de una violación de datos que afecte tu información personal:

- Te notificaremos dentro de las 72 horas posteriores al descubrimiento de la violación
- Proporcionaremos detalles sobre qué datos se vieron afectados
- Describiremos los pasos que estamos tomando para abordar la violación
- Recomendaremos acciones que puedes tomar para protegerte

## 12. Cambios en Esta Política de Privacidad

Podemos actualizar esta Política de Privacidad de vez en cuando. Te notificaremos de cambios materiales mediante:

- Publicación de la política actualizada en la aplicación
- Envío de una notificación por correo electrónico a tu correo registrado
- Visualización de un aviso en la aplicación

Tu uso continuado de Lifeline después de los cambios indica la aceptación de la política actualizada.

## 13. Contáctanos

Si tienes preguntas, inquietudes o solicitudes respecto a esta Política de Privacidad o tus datos, contáctanos:

**Email:** founder@theplacewelive.org

**Tiempo de respuesta:** Nuestro objetivo es responder a todas las consultas dentro de los 7 días hábiles.

## 14. Informe de Transparencia

Estamos comprometidos con la transparencia. A solicitud, podemos proporcionar información sobre:

- Número de solicitudes de datos recibidas de autoridades
- Tipos de datos solicitados
- Nuestras respuestas a tales solicitudes

---

*Esta Política de Privacidad se actualizó por última vez el 2 de octubre de 2025. Las versiones anteriores están disponibles a solicitud.*

**Al usar Lifeline, reconoces que has leído y comprendido esta Política de Privacidad y aceptas nuestras prácticas de datos como se describen.**

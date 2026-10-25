# asking-questions

Regla general para toda pregunta al operador mientras se aplica el skill, en [`../SKILL.md`](../SKILL.md) y en los flujos que enlaza. Se hace con la herramienta `AskUserQuestion` (recuadro con opciones seleccionables por clic o teclado), no como texto en el chat (el contexto que acompaña a la pregunta sí va como texto, ver la regla 5). Rige también para las preguntas abiertas.

1. **Con opciones:** de 2 a 4 por pregunta, la recomendada primero y marcada «(Recomendado)». La herramienta agrega sola «Otro», donde el operador escribe libre: no se escribe como opción.
2. **Abiertas:** la herramienta exige al menos 2 opciones, así que se ofrecen candidatos razonables (ej. el nombre que se detectó en `package.json` o en la carpeta); si no hay, dos genéricas («Lo escribo yo», «No aplica / omitir»). La respuesta va en «Otro». No pedir respuestas en texto dentro de la misma tanda que el widget; el mensaje de contexto previo de la regla 5 es aparte.
3. **Tandas:** hasta 4 preguntas por llamada, mostradas juntas. Las que dependen de una respuesta anterior van en llamadas separadas.
4. **Respaldo:** solo si el cliente no tiene la herramienta, preguntar en texto con las mismas opciones numeradas.
5. **Contexto primero, preguntas cortas:** todo lo que el operador necesite revisar para responder (plan, tabla, resumen, lista, diff, la evidencia de una recomendación) se escribe completo en un mensaje del chat antes de llamar a la herramienta. El recuadro lleva solo la pregunta (una frase que remite al contexto, ej. «¿Los pasos del plan están bien?») y opciones con etiqueta corta; la descripción de una opción dice en una línea qué pasa al elegirla, nunca contiene el contenido a revisar. Si la pregunta no necesita contexto (ej. idioma), va sola.

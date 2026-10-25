# Actualizar un proyecto a la versión actual de la skill

Aplica al proyecto los cambios descritos en [`changelog/`](./changelog/README.md), en una rama nueva. Solo edita lo que el operador confirma.

## Cuándo

Solo desde [`version-check.md`](./version-check.md), cuando el operador elige «Actualizar». No migra documentación de otros sistemas ([`migration-flow.md`](./migration-flow.md)).

## Precondiciones

- Repo git. Si no lo es, avisar que no habría cómo revertir y pedir confirmación explícita (`AskUserQuestion`) antes de seguir sin rama.
- Git limpio, según [«Precondición: git limpio»](./migration-flow.md#precondición-git-limpio). Aquí, si hay cambios sin commitear, no se sigue con confirmación: se pide que se commiteen o guarden y se para.
- Crear la rama `agent-context-update-<versión destino>` desde la actual (`git switch -c`; si existe, sufijo numérico). Nunca se trabaja en la rama principal ni se hace merge.

## Qué leer

Política de lectura de [`../SKILL.md`](../SKILL.md): por rangos, sin abrir archivos enteros.

1. Listar `docs/changelog/` y ordenar los `X.Y.md` numéricamente.
2. Tomar desde el `X.Y` del proyecto (marcador ausente = desde `1.9`) hasta el de la skill.
3. Dentro, solo las secciones `## X.Y.Z` con versión mayor que la del proyecto y menor o igual que la de la skill.
4. Si falta el archivo de alguna serie intermedia: avisar, no actualizar por changelog y ofrecer «Solo revisar» ([`version-check.md`](./version-check.md)).
5. Descartar los cambios con `Modo: multi` si el proyecto no tiene `operators.md`.

## Resumen previo

Antes de tocar nada, un resumen único escrito completo en el chat, antes de pedir nada (como la «Ronda de confirmación» de [`migration-flow.md`](./migration-flow.md)): lista de cambios con versión, título, archivo, tipo y estado (aplicable / ya aplicado / conflicto / manual).

## Aplicar

En orden, de la versión más vieja a la más nueva, confirmando cada cambio con `AskUserQuestion` («Aplicar» / «Omitir»). Cada cambio (versión, título, texto anterior/nuevo o instrucción) se muestra en el chat antes de su pregunta; si los cambios son independientes entre sí (no tocan el mismo archivo/sección ni dependen de un conflicto previo) se pueden mostrar todos antes y preguntar en tandas de hasta 4, cada pregunta con un header distinto de ≤12 caracteres (ej. `Cambio 1`, `Cambio 2`); si no, uno por llamada (regla 3 de [`asking-questions.md`](./asking-questions.md)).

- **Comparación:** el «texto anterior» debe coincidir con lo que tiene el proyecto. Si el texto nuevo ya está → «ya aplicado», se salta. Si no coincide → conflicto: escribir en el chat la diferencia (texto del proyecto frente al texto nuevo) y, después, preguntar «Conservar el del proyecto» / «Pisar con el nuevo» / «Fusionar a mano».
- **Idioma:** el changelog está en el idioma de la plantilla (español). Si `IDIOMA` del proyecto es otro, no se compara literal sino por sentido y el texto nuevo se escribe traducido a `IDIOMA` (solo el marcador va literal).
- **Tipo `manual`:** mostrar la instrucción y ofrecer ayuda; no se automatiza.
- `{{versión}}` = versión de la skill.

## Marcador

Al final, actualizar la línea 1 de `rules.md` a la versión de la skill solo si todos los cambios aplicables se aplicaron o se resolvieron. Si se omitió alguno, listar en el chat los cambios omitidos y preguntar si subirlo igual (advertir que oculta lo pendiente; por defecto no).

## Cierre

Con confirmación, un commit en la rama nueva (`docs: actualizar la documentación de la skill de X a Y`). Informar el nombre de la rama, el resumen de aplicados/omitidos/manuales y cómo revisar (`git diff <rama principal>`). No hace merge: lo decide el operador.

## Alcance

No toca `handoff.md`, `backlog.md` ni `history.md`, salvo cambios `manual` que el operador apruebe.

"""Genera los tres SVG del icono con el texto ya convertido a curvas.

    py -m pip install fonttools
    py tool/build_icons.py

El wordmark queda como curvas para que el .svg no dependa de que Brush Script
MT esté instalada. El precio es que no se edita a mano: para cambiar el texto,
el tamaño o la fuente hay que tocar las constantes de aquí y volver a correrlo.

Los PNG de 1024 que consume flutter_launcher_icons se rasterizan aparte. Con
Chrome, que ya está en la máquina:

    chrome --headless --default-background-color=00000000 \\
           --screenshot=assets/icons/app_icon.png --window-size=1024,1024 \\
           assets/icons/app_icon.svg

La ventana tiene que medir 1024: el SVG declara ese tamaño y Chrome lo dibuja
a escala 1:1, así que una ventana más chica recorta en vez de reducir.
"""
import re
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.misc.transform import Transform

OUT = Path(__file__).resolve().parent.parent / "assets" / "icons"
TEXT, SIZE, BASE = "La Valiente", 176.0, 858.0
# 516 y no 512: centrar por ancho de avance deja la tinta 4 px a la izquierda.
CX = 516.0

f = TTFont(r"C:\Windows\Fonts\BRUSHSCI.TTF")
upem, cmap, gs, hmtx = f["head"].unitsPerEm, f.getBestCmap(), f.getGlyphSet(), f["hmtx"]
kern = {}
if "kern" in f:
    for st in f["kern"].kernTables:
        kern.update(st.kernTable)

names = [cmap[ord(c)] for c in TEXT]
total = sum(hmtx[n][0] for n in names) + sum(
    kern.get((names[i], names[i + 1]), 0) for i in range(len(names) - 1)
)
s = SIZE / upem
x = CX - total * s / 2
pen = SVGPathPen(gs)
for i, n in enumerate(names):
    gs[n].draw(TransformPen(pen, Transform(s, 0, 0, -s, x, BASE)))
    x += hmtx[n][0] * s
    if i + 1 < len(names):
        x += kern.get((names[i], names[i + 1]), 0) * s

d = re.sub(r"-?\d+\.\d+", lambda m: f"{float(m.group()):.1f}".rstrip("0").rstrip("."), pen.getCommands())

DEFS = """    <linearGradient id="lv-bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#EC5AAC"/>
      <stop offset="0.42" stop-color="#E2168B"/>
      <stop offset="1" stop-color="#A50E67"/>
    </linearGradient>
    <linearGradient id="lv-glass" x1="0.2" y1="0" x2="0.8" y2="1">
      <stop offset="0" stop-color="#A9E4F9"/>
      <stop offset="0.55" stop-color="#49C5F3"/>
      <stop offset="1" stop-color="#1B84B8"/>
    </linearGradient>
    <radialGradient id="lv-glow" cx="0.26" cy="0.18" r="0.9">
      <stop offset="0" stop-color="#FFFFFF" stop-opacity="0.20"/>
      <stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/>
    </radialGradient>
    <filter id="lv-lift" x="-30%" y="-30%" width="160%" height="160%">
      <feDropShadow dx="0" dy="14" stdDeviation="18" flood-color="#59062F" flood-opacity="0.35"/>
    </filter>
    <clipPath id="lv-drum"><circle cx="512" cy="404" r="140"/></clipPath>"""

MACHINE = f"""    <!-- Cuerpo y panel. El panel son dos rectangulos: el primero redondea las
         cuatro esquinas y el segundo vuelve a cuadrar las de abajo. -->
    <rect x="286" y="150" width="452" height="512" rx="58" fill="#FFFFFF"/>
    <rect x="286" y="150" width="452" height="116" rx="58" fill="#F49BCE"/>
    <rect x="286" y="208" width="452" height="58" fill="#F49BCE"/>
    <rect x="334" y="186" width="168" height="44" rx="22" fill="#FFFFFF" opacity="0.75"/>
    <circle cx="668" cy="208" r="28" fill="#FFFFFF" opacity="0.9"/>
    <!-- Escotilla -->
    <circle cx="512" cy="404" r="140" fill="url(#lv-glass)"/>
    <circle cx="512" cy="404" r="164" fill="none" stroke="#F49BCE" stroke-width="34"/>
    <g clip-path="url(#lv-drum)" fill="#FFFFFF">
      <circle cx="466" cy="358" r="38" opacity="0.95"/>
      <circle cx="556" cy="422" r="26" opacity="0.9"/>
      <circle cx="474" cy="466" r="17" opacity="0.85"/>
    </g>
    <!-- "La Valiente" en Brush Script MT, ya convertido a curvas: asi el
         archivo no depende de que la fuente este instalada. Para reescribirlo
         hay que volver a generarlo, no se edita a mano. -->
    <path fill="#FFFFFF" d="{d}"/>"""

BUBBLES = """    <g fill="#49C5F3" opacity="0.55">
      <circle cx="182" cy="188" r="32"/>
      <circle cx="256" cy="126" r="18"/>
      <circle cx="856" cy="168" r="22"/>
    </g>"""

icon = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024" role="img" aria-label="La Valiente">
  <title>La Valiente</title>
  <!-- GENERADO por tool/build_icons.py. El texto son curvas; editarlo a mano
       no es viable. Cambia el script y volve a correrlo.

       El magenta a proposito NO se degrada hacia el cian: la mezcla lineal
       entre #E2168B y #49C5F3 pasa por un violeta grisaceo. El cian entra como
       figura aparte (la escotilla y las burbujas), igual que en el logo. -->
  <defs>
{DEFS}
  </defs>

  <rect width="1024" height="1024" rx="232" fill="url(#lv-bg)"/>
  <rect width="1024" height="1024" rx="232" fill="url(#lv-glow)"/>

{BUBBLES}

  <g filter="url(#lv-lift)">
{MACHINE}
  </g>
</svg>
"""

# Capa de frente del icono adaptativo. Android solo garantiza visible el
# circulo central de 66dp sobre 108dp = r 313 px sobre 1024. La lavadora y el
# texto ocupan x 176..848, y 150..867 (centro 512, 508.75), cuya esquina mas
# lejana queda a r 486 con escala 1.
#
# El 0.90 NO es el numero que hace caber eso por si solo (seria 0.63):
# flutter_launcher_icons envuelve esta capa en un <inset android:inset="16%">,
# que la redibuja al 68%. Las dos reducciones se multiplican, asi que aqui hay
# que compensar. 486 x 0.90 x 0.68 = 297, dentro de los 313. Si algun dia se
# usa este SVG sin ese inset, hay que bajarlo a 0.63.
foreground = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024" role="img" aria-label="La Valiente">
  <title>La Valiente — capa de frente (icono adaptativo de Android)</title>
  <!-- GENERADO por tool/build_icons.py.

       Fondo transparente a proposito: el color lo pone app_icon_background.svg.
       Android recorta esta capa con la mascara que elija el fabricante
       (circulo, squircle, gota), y solo garantiza el circulo central de 66dp
       sobre 108dp — r = 313 px sobre 1024.

       La escala 0.90 esta calculada CONTANDO con que flutter_launcher_icons
       envuelve esta capa en un <inset android:inset="16%">. Sin ese inset la
       marca se sale; con el, cae en r = 297. Ver tool/build_icons.py.

       Se ve mas chico que el icono de iOS y asi debe ser: en el lanzador solo
       se asoman 72dp de los 108. -->
  <defs>
{DEFS}
  </defs>

  <g transform="translate(512 512) scale(0.90) translate(-512 -508.75)" filter="url(#lv-lift)">
{MACHINE}
  </g>
</svg>
"""

background = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024" role="img" aria-label="Fondo de marca">
  <title>La Valiente — capa de fondo (icono adaptativo de Android)</title>
  <!-- Va a sangre y sin esquinas redondeadas: el redondeo lo aplica la mascara
       del sistema, y si lo trajera el archivo se veria un borde doble.
       El equivalente plano es adaptive_icon_background: "#E2168B". -->
  <defs>
    <linearGradient id="lv-bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#EC5AAC"/>
      <stop offset="0.42" stop-color="#E2168B"/>
      <stop offset="1" stop-color="#A50E67"/>
    </linearGradient>
    <radialGradient id="lv-glow" cx="0.26" cy="0.18" r="0.9">
      <stop offset="0" stop-color="#FFFFFF" stop-opacity="0.20"/>
      <stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="1024" height="1024" fill="url(#lv-bg)"/>
  <rect width="1024" height="1024" fill="url(#lv-glow)"/>
</svg>
"""

OUT.mkdir(parents=True, exist_ok=True)
for name, body in [
    ("app_icon.svg", icon),
    ("app_icon_foreground.svg", foreground),
    ("app_icon_background.svg", background),
]:
    (OUT / name).write_text(body, encoding="utf-8")
    print(f"{name}  {len(body):,} bytes")

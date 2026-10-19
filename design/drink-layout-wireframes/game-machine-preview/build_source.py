from pathlib import Path
import base64
HERE=Path(__file__).parent
ROOT=HERE.parents[2]
source=(HERE.parent/'a-right-card.svg').read_text(encoding='utf-8')
start=source.index('<rect x="365" y="160"')
end=source.index('<rect x="862" y="241"')
sprite=base64.b64encode((ROOT/'images/vending_approved_15.png').read_bytes()).decode()
image=f'<image x="408" y="135" width="384" height="576" preserveAspectRatio="xMidYMid meet" href="data:image/png;base64,{sprite}"/>'
result=source[:start]+image+source[end:]
# Source art's ion display center, while leaving the right card where A places it.
old='<line x1="674.0" y1="285.0"'
result=result.replace(old,'<line x1="631" y1="273"')
(HERE/'layout.svg').write_text(result,encoding='utf-8')
print('Embedded original game texture: 384 x 576 / 2:3')

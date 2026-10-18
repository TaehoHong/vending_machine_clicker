from pathlib import Path
import json
R=Path(__file__).resolve().parents[1]
TOK=json.loads((R/'design/penpot-ui/tokens.json').read_text(encoding='utf-8-sig'))
C=TOK['colors']
def color(h):
 h=h.lstrip('#');return 'Color('+', '.join(str(round(int(h[i:i+2],16)/255,5)) for i in [0,2,4])+', 1)'
def q(t):return json.dumps(t,ensure_ascii=False)
def style(id,bg,border=None,radius=10):
 s=f'[sub_resource type="StyleBoxFlat" id="{id}"]\n'
 s+=f'bg_color = {color(bg)}\n'
 if border:
  s+=''.join(f'border_width_{side} = 1\n' for side in ['left','top','right','bottom'])+f'border_color = {color(border)}\n'
 s+=''.join(f'corner_radius_{c} = {radius}\n' for c in ['top_left','top_right','bottom_left','bottom_right'])
 s+=('content_margin_left = 0.0\ncontent_margin_right = 0.0\ncontent_margin_top = 0.0\ncontent_margin_bottom = 0.0\n' if id in ['Panel','Bar','Fill','Focus'] else 'content_margin_left = 16.0\ncontent_margin_right = 16.0\ncontent_margin_top = 8.0\ncontent_margin_bottom = 8.0\n')
 if id=='Focus':s+='draw_center = false\n'
 return s+'\n'
s='[gd_resource type="Theme" format=3]\n\n'
s+='[sub_resource type="SystemFont" id="Font"]\nfont_names = PackedStringArray("Malgun Gothic", "맑은 고딕")\n\n'
for args in [('Panel',C['panel'],C['edge'],16),('Normal','#182633',C['edge'],10),('Hover','#243949',C['gold'],10),('Pressed','#26313A',C['gold'],10),('Disabled','#15202B',None,10),('Primary',C['gold'],None,10),('PrimaryHover','#FFCF7D',None,10),('PrimaryPressed','#DDA74D',None,10),('Focus',C['panel'],C['gold'],10),('Bar','#293744',None,3),('Fill',C['gold'],None,3),('Ghost',C['bg'],None,0)]:s+=style(*args)
s+='[sub_resource type="SystemFont" id="Bold"]\nfont_names = PackedStringArray("Malgun Gothic", "맑은 고딕")\nfont_weight = 700\n\n'
s+='[resource]\ndefault_font = SubResource("Font")\ndefault_font_size = 16\n'
for cls in ['Label','RichTextLabel','Button']:
 s+=f'{cls}/colors/font_color = {color(C["text"])}\n'
s+='Label/colors/font_shadow_color = Color(0,0,0,0)\n'
for state in ['normal','hover','pressed','disabled','focus']:
 s+=f'Button/styles/{state} = SubResource("{dict(normal="Normal",hover="Hover",pressed="Pressed",disabled="Disabled",focus="Focus")[state]}")\n'
s+=f'Button/colors/font_disabled_color = {color("#687783")}\nButton/font_sizes/font_size = 18\n'
s+='Button/fonts/font = SubResource("Bold")\n'
s+='PrimaryButton/base_type = &"Button"\n'
for state,sty in [('normal','Primary'),('hover','PrimaryHover'),('pressed','PrimaryPressed'),('focus','Focus'),('disabled','Disabled')]:s+=f'PrimaryButton/styles/{state} = SubResource("{sty}")\n'
for state in ['font_color','font_hover_color','font_pressed_color','font_focus_color']:s+=f'PrimaryButton/colors/{state} = {color(C["bg"])}\n'
s+='Panel/styles/panel = SubResource("Panel")\nPanelContainer/styles/panel = SubResource("Panel")\nProgressBar/styles/background = SubResource("Bar")\nProgressBar/styles/fill = SubResource("Fill")\n'
(R/'ui/backstreet_theme.tres').write_text(s,encoding='utf-8')

class Scene:
 def __init__(self,uid,script,bg):
  self.s=f'[gd_scene format=3 uid="{uid}"]\n\n[ext_resource type="Script" path="res://{script}" id="1"]\n[ext_resource type="Texture2D" path="res://images/{bg}" id="2"]\n[ext_resource type="Theme" path="res://ui/backstreet_theme.tres" id="theme"]\n[ext_resource type="SystemFont" path="res://ui/bold_font.tres" id="bold"]\n'
 def node(self,name,typ,parent=None,box=None,props=''):
  self.s+=f'\n[node name="{name}" type="{typ}"'+(f' parent="{parent}"' if parent is not None else '')+']\n'
  if box:
   x,y,w,h=box;self.s+=f'layout_mode = 0\noffset_left = {float(x)}\noffset_top = {float(y)}\noffset_right = {float(x+w)}\noffset_bottom = {float(y+h)}\n'
  self.s+=props+'\n'
 def label(self,name,parent,box,text,size=16,col=None,extra=''):
  self.node(name,'Label',parent,box,f'theme_override_fonts/font = ExtResource("bold")\n'*(1 if name in ['TitleLabel','MoneyLabel','DrinkName','QuestTitle','Title','Brand'] else 0)+f'text = {q(text)}\ntheme_override_font_sizes/font_size = {size}\n'+(f'theme_override_colors/font_color = {color(col)}\n' if col else '')+'mouse_filter = 2\n'+extra)
 def button(self,name,parent,box,text,primary=False,extra=''):
  self.node(name,'Button',parent,box,f'text = {q(text)}\nmouse_default_cursor_shape = 2\n'+('theme_type_variation = &"PrimaryButton"\n' if primary else '')+extra)
 def connect(self,src,method,to='.'):
  self.s+=f'\n[connection signal="pressed" from="{src}" to="{to}" method="{method}"]\n'
 def write(self,file): (R/file).write_text(self.s,encoding='utf-8')
FULL='layout_mode = 1\nanchors_preset = 15\nanchor_right = 1.0\nanchor_bottom = 1.0\ngrow_horizontal = 2\ngrow_vertical = 2\n'
RIGHT='anchor_left = 1.0\nanchor_right = 1.0\ngrow_horizontal = 0\n'
def base(sc,name):
 sc.node(name,'Control',props=FULL+'theme = ExtResource("theme")\nscript = ExtResource("1")')
 sc.node('BackgroundImage' if name=='Main' else 'TextureRect','TextureRect','.',props=FULL+'texture = ExtResource("2")\nmouse_filter = 2\nexpand_mode = 1\nstretch_mode = 6')
def gradient(sc,menu=False):
 # A native GradientTexture2D keeps the foreground readable as in Penpot.
 g='MenuShade' if menu else 'GameShade'
 idx=sc.s.index('\n[node')
 resources=f'\n[sub_resource type="Gradient" id="{g}"]\ncolors = PackedColorArray(0.031,0.059,0.094,0.97, 0.031,0.059,0.094,0.12)\n[sub_resource type="GradientTexture2D" id="{g}Tex"]\ngradient = SubResource("{g}")\nwidth = 1152\nheight = 648\nfill_from = Vector2(0,0)\nfill_to = Vector2(1,0)\n'
 sc.s=sc.s[:idx]+resources+sc.s[idx:]
 sc.node('Shade','TextureRect','.',props=FULL+f'texture = SubResource("{g}Tex")\nexpand_mode = 1\nmouse_filter = 2'+('' if menu else '\nmodulate = Color(1,1,1,0.2)'))

m=Scene('uid://c2ws7d5q7yw4v','main.gd','ef7fdf44-d785-487d-be87-8d480ea063ca.png');base(m,'Main');gradient(m,True)
m.label('Brand','.',(64,46,450,24),'夜の路地 / BACKSTREET',12,C['gold'])
m.node('MenuBox','Control','.',(64,113,380,450))
m.node('Accent','ColorRect','MenuBox',(0,0,46,4),'color = '+color(C['gold'])+'\nmouse_filter = 2')
m.label('TitleLabel','MenuBox',(0,30,500,110),'BACKSTREET\nCLICKER',48,extra='theme_override_constants/line_spacing = -6')
m.label('Subtitle','MenuBox',(2,150,460,30),'골목의 작은 동전으로, 나만의 자판기를.',17,C['muted'])
m.button('NewGameButton','MenuBox',(0,213,320,54),'New Game   →',True, 'tooltip_text = "기존 저장을 백업하고 새 게임을 시작합니다."')
m.button('LoadGameButton','MenuBox',(0,279,320,54),'Load Game')
m.label('SaveSummary','MenuBox',(0,346,420,26),'저장된 게임이 없습니다.',12,C['muted'])
m.node('Divider','ColorRect','MenuBox',(0,394,320,1),'color = '+color(C['edge'])+'\nmouse_filter = 2')
m.button('SettingsButton','MenuBox',(0,410,112,32),'Settings',extra='flat = true\ndisabled = true\ntooltip_text = "설정 기능은 준비 중입니다."\ntheme_override_font_sizes/font_size = 15')
m.button('ExitButton','MenuBox',(248,410,72,32),'Exit',extra='flat = true\ntheme_override_font_sizes/font_size = 15')
m.label('Status','MenuBox',(0,450,460,36),'',13,C['gold'], 'autowrap_mode = 2')
m.label('Footer','.',(64,588,450,26),'拾う。飲む。育てる。',12,C['muted'])
for src,method in [('NewGameButton','_on_new_game_button_pressed'),('LoadGameButton','_on_load_game_button_pressed'),('ExitButton','_on_exit_button_pressed')]:m.connect('MenuBox/'+src,method)
m.write('main.tscn')

g=Scene('uid://76phghpoy71h','game.gd','2847210d-a3b0-4e7a-964a-049414535f65.png');g.s+='\n[ext_resource type="Script" path="res://pause_menu.gd" id="pause"]\n[ext_resource type="Texture2D" path="res://ui/reward_halo.svg" id="halo"]\n[ext_resource type="Texture2D" path="res://ui/search_glow.svg" id="search_glow"]\n[ext_resource type="Texture2D" path="res://ui/can_icon.svg" id="can_icon"]\n[ext_resource type="Texture2D" path="res://images/drinks/water_pop.tres" id="water_art"]\n[ext_resource type="Texture2D" path="res://images/drinks/green_tea_pop.tres" id="tea_art"]\n[ext_resource type="Texture2D" path="res://images/drinks/ion_drink_pop.tres" id="ion_art"]\n[ext_resource type="Script" path="res://ui/skill_tree.gd" id="skill_tree"]\n[ext_resource type="ShaderMaterial" path="res://ui/search_glow.tres" id="glow_material"]\n';base(g,'Game');gradient(g)
g.label('Brand','.',(32,22,400,26),'BACKSTREET / CLICKER',13,C['gold'])
g.button('MenuButton','.',(-132,18,104,32),'ESC  메뉴',extra=RIGHT+'flat = true\ntheme_override_font_sizes/font_size = 13')
g.node('WalletPanel','Panel','.',(28,64,246,132))
g.label('WalletCaption','WalletPanel',(20,14,140,24),'보유 금액',13,C['muted'])
g.label('Currency','WalletPanel',(164,56,60,24),'Gold',17,C['gold'], 'horizontal_alignment = 2')
g.label('MoneyLabel','.',(48,98,210,48),'0',32)
g.node('CanIcon','TextureRect','WalletPanel',(20,94,22,26),'texture = ExtResource("can_icon")\nexpand_mode = 1\nstretch_mode = 5\nmouse_filter = 2')
g.label('CanCount','WalletPanel',(52,91,170,30),'0',18,C['muted'])
g.node('Navigation','Control','.',(28,-78,246,50),'anchor_top = 1.0\nanchor_bottom = 1.0')
g.button('AbilityButton','Navigation',(0,0,117,50),'능력')
g.button('SkillButton','Navigation',(129,0,117,50),'스킬')
g.node('QuestPanel','Panel','.',(-290,64,262,154),RIGHT)
g.label('QuestTitle','QuestPanel',(20,14,230,28),'첫 수집 목표',17)
g.label('QuestText','QuestPanel',(20,48,230,24),'동전 10번 발견하기',14,C['muted'])
g.node('QuestBar','ProgressBar','QuestPanel',(20,76,222,5),'show_percentage = false\nmax_value = 10.0\nmouse_filter = 2')
g.label('QuestProgress','QuestPanel',(20,84,94,24),'0 / 10',13,C['gold'])
g.label('RewardHint','QuestPanel',(132,84,110,24),'보상 ¥5000',13,C['muted'],'horizontal_alignment = 2')
g.button('QuestCompleteButton','QuestPanel',(20,108,222,34),'보상 받기 · ¥5000',True,'theme_override_font_sizes/font_size = 13')
g.button('CoinSlotButton','.',(640,289,36,74),'',extra='accessibility_name = "자판기 동전 투입구 · 물품 구매"')
g.node('SlotHint','Panel','.',(699,302,190,44),'mouse_filter = 2')
g.label('Price','SlotHint',(16,9,160,24),'100 Gold 투입',16,C['gold'])
g.node('CoinToken','Panel','.',(0,0,42,42),'visible = false\nz_index = 10\nmouse_filter = 2')
g.label('Symbol','CoinToken',(0,0,42,42),'¥',25,'#593305','horizontal_alignment = 1\nvertical_alignment = 1')
g.label('FeedbackLabel','.',(28,-90,1096,40),'',14,C['gold'],'anchor_top = 1.0\nanchor_bottom = 1.0\nanchor_right = 1.0\noffset_right = -28.0\nhorizontal_alignment = 1\nautowrap_mode = 2')
g.node('SearchGlow','TextureRect','.',(420,445,310,125),'mouse_filter = 2\ntexture = ExtResource("search_glow")\nmaterial = ExtResource("glow_material")\nexpand_mode = 1\nmodulate = Color(1,1,1,0)')
g.button('EarnButton','.',(458,448,230,110),'',extra='flat = true\nfocus_mode = 0\naccessibility_name = "자판기 밑 수색"')
g.node('ResultOverlay','ColorRect','.',props=FULL+'visible = false\ncolor = Color(0.043,0.067,0.094,0.84)')
g.node('Card','PanelContainer','ResultOverlay',(-240,-284,480,568),'anchor_left = 0.5\nanchor_right = 0.5\nanchor_top = 0.5\nanchor_bottom = 0.5')
g.node('Margin','MarginContainer','ResultOverlay/Card',props='layout_mode = 2\ntheme_override_constants/margin_left = 32\ntheme_override_constants/margin_right = 32\ntheme_override_constants/margin_top = 22\ntheme_override_constants/margin_bottom = 22')
g.node('Contents','Control','ResultOverlay/Card/Margin',props='layout_mode = 2')
p='ResultOverlay/Card/Margin/Contents'
g.label('Heading',p,(0,0,416,22),'VENDING MACHINE / 100 JPY',11,C['gold'],'horizontal_alignment = 1')
g.label('DrinkName',p,(0,32,416,42),'',30,extra='horizontal_alignment = 1')
g.node('Halo','TextureRect',p,(80,94,256,256),'texture = ExtResource("halo")\nexpand_mode = 1\nmouse_filter = 2')
g.node('DrinkArt','TextureRect',p,(96,81,224,280),'expand_mode = 1\nstretch_mode = 5\nmouse_filter = 2')
g.node('Divider','ColorRect',p,(0,370,416,1),'color = '+color(C['edge'])+'\nmouse_filter = 2')
g.node('Effect','RichTextLabel',p,(0,388,416,84),'bbcode_enabled = true\nscroll_active = false\nmouse_filter = 2\ntheme_override_font_sizes/normal_font_size = 13')
g.button('CloseButton',p,(0,478,416,46),'닫기',True)
g.node('InfoOverlay','ColorRect','.',props=FULL+'visible = false\ncolor = Color(0.043,0.067,0.094,0.84)')
g.node('Card','Panel','InfoOverlay',(-280,-280,560,560),'anchor_left = 0.5\nanchor_right = 0.5\nanchor_top = 0.5\nanchor_bottom = 0.5')
g.label('Title','InfoOverlay/Card',(28,22,504,40),'능력',28,extra='horizontal_alignment = 1')
catalog=json.loads((R/'ui/drinks.json').read_text(encoding='utf-8'))
# Scroll keeps every unlocked drink and the full top-down tree accessible.
idx=g.s.index('[sub_resource')
extras=''.join(f'[ext_resource type="Texture2D" path="{d["asset"]}" id="drink_{i}"]\n' for i,d in enumerate(catalog))
g.s=g.s[:idx]+extras+g.s[idx:]
g.node('Catalog','ScrollContainer','InfoOverlay/Card',(28,78,504,264),'horizontal_scroll_mode = 0')
g.node('Rows','VBoxContainer','InfoOverlay/Card/Catalog',props='layout_mode = 2\nsize_flags_horizontal = 3\ntheme_override_constants/separation = 8')
for i,d in enumerate(catalog):
 parent='InfoOverlay/Card/Catalog/Rows'
 g.node(d['key'],'Panel',parent,props='layout_mode = 2\ncustom_minimum_size = Vector2(480,82)')
 g.node('Art','TextureRect',parent+'/'+d['key'],(12,6,58,70),f'texture = ExtResource("drink_{i}")\nexpand_mode = 1\nstretch_mode = 5\nmouse_filter = 2')
 g.label('Name',parent+'/'+d['key'],(86,4,360,26),d['name']+' 캔',19,d['color'])
 g.label('Count',parent+'/'+d['key'],(86,29,380,22),'획득 0개',16)
 g.label('Rule',parent+'/'+d['key'],(86,55,390,22),d['effect'],12,C['muted'])
g.node('SkillTree','ScrollContainer','InfoOverlay/Card',(28,82,504,390),'visible = false\nhorizontal_scroll_mode = 0\nscript = ExtResource("skill_tree")')
g.node('Summary','RichTextLabel','InfoOverlay/Card',(28,312,504,172),'bbcode_enabled = true\nscroll_active = false\nmouse_filter = 2\ntheme_override_font_sizes/normal_font_size = 16')
g.button('CloseButton','InfoOverlay/Card',(28,496,504,42),'닫기',True)
g.node('PauseMenu','CanvasLayer','.',props='process_mode = 3\nlayer = 20\nscript = ExtResource("pause")')
g.node('Overlay','ColorRect','PauseMenu',props=FULL+'visible = false\ntheme = ExtResource("theme")\ncolor = Color(0.043,0.067,0.094,0.84)')
g.node('Card','PanelContainer','PauseMenu/Overlay',(-200,-218,400,436),'anchor_left = 0.5\nanchor_right = 0.5\nanchor_top = 0.5\nanchor_bottom = 0.5')
g.node('Margin','MarginContainer','PauseMenu/Overlay/Card',props='layout_mode = 2\ntheme_override_constants/margin_left = 32\ntheme_override_constants/margin_right = 32\ntheme_override_constants/margin_top = 24\ntheme_override_constants/margin_bottom = 24')
g.node('Buttons','Control','PauseMenu/Overlay/Card/Margin',props='layout_mode = 2')
p='PauseMenu/Overlay/Card/Margin/Buttons'
g.label('Eyebrow',p,(0,0,336,22),'PAUSED',11,C['gold'],'horizontal_alignment = 1')
g.label('Title',p,(0,34,336,42),'잠시 쉬어가세요',27,extra='horizontal_alignment = 1')
g.label('Subtitle',p,(0,78,336,24),'골목은 그대로 기다리고 있어요.',13,C['muted'],'horizontal_alignment = 1')
for n,t,y,primary in [('ResumeButton','계속',120,True),('SaveButton','저장',188,False),('QuitButton','끝내기',256,False)]:g.button(n,p,(0,y,336,54),t,primary)
g.label('Status',p,(0,324,336,28),'끝내기를 누르면 저장 후 종료합니다.',12,C['muted'],'horizontal_alignment = 1\nautowrap_mode = 2')
g.label('EscapeHint',p,(0,360,336,24),'ESC  게임으로 돌아가기',12,C['gold'],'horizontal_alignment = 1')
for src,method,to in [('QuestPanel/QuestCompleteButton','_on_quest_complete_button_pressed','.'),('EarnButton','_on_earn_button_pressed','.'),('CoinSlotButton','_on_shop_button_pressed','.'),('MenuButton','_on_menu_button_pressed','.'),('ResultOverlay/Card/Margin/Contents/CloseButton','_on_result_close_pressed','.')]:g.connect(src,method,to)
for n,method in [('ResumeButton','_on_resume_pressed'),('SaveButton','_on_save_pressed'),('QuitButton','_on_quit_pressed')]:g.connect(p+'/'+n,method,'PauseMenu')
g.s+='\n[connection signal="save_requested" from="PauseMenu" to="." method="_on_pause_save_requested"]\n[connection signal="quit_requested" from="PauseMenu" to="." method="_on_pause_quit_requested"]\n'
g.connect('Navigation/AbilityButton','_on_ability_button_pressed')
g.connect('Navigation/SkillButton','_on_skill_button_pressed')
g.connect('InfoOverlay/Card/CloseButton','_on_info_close_pressed')
g.s+='\n[connection signal="unlock_requested" from="InfoOverlay/Card/SkillTree" to="." method="_on_unlock_drink_requested"]\n'
g.write('Game.tscn')
print('Generated native Godot scenes and shared theme from Penpot tokens.')


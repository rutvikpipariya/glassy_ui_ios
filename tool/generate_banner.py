#!/usr/bin/env python3
"""Renders screenshots/banner.png. Usage: python3 tool/generate_banner.py ."""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
R=sys.argv[1]
W,H=1600,800
bg=Image.new('RGB',(W,H)); px=bg.load()
top=(10,12,32); mid=(46,22,92); end=(120,30,110)
for y in range(H):
    for x in range(W):
        t=(x/W*0.7+y/H*0.3)
        if t<0.6: a=t/0.6; c=tuple(int(top[i]+(mid[i]-top[i])*a) for i in range(3))
        else: a=(t-0.6)/0.4; c=tuple(int(mid[i]+(end[i]-mid[i])*a) for i in range(3))
        px[x,y]=c
glow=Image.new('RGB',(W,H)); g=ImageDraw.Draw(glow)
g.ellipse((900,-200,1500,400),fill=(60,120,255)); g.ellipse((1150,420,1750,1000),fill=(255,80,160)); g.ellipse((-200,500,400,1100),fill=(90,60,220))
bg=Image.blend(bg,glow.filter(ImageFilter.GaussianBlur(160)),0.45)
def font(size,weight='Bold',f='/System/Library/Fonts/SFNS.ttf'):
    ft=ImageFont.truetype(f,size)
    try: ft.set_variation_by_name(weight)
    except Exception: pass
    return ft
def phone(path,w):
    im=Image.open(path).convert('RGB'); h=int(im.height*w/im.width); im=im.resize((w,h),Image.LANCZOS)
    b=12; fr=Image.new('RGBA',(w+2*b,h+2*b),(0,0,0,0)); d=ImageDraw.Draw(fr)
    d.rounded_rectangle((0,0,w+2*b-1,h+2*b-1),radius=int(w*0.16),fill=(18,18,22,255),outline=(80,80,92,255),width=3)
    m=Image.new('L',(w,h),0); ImageDraw.Draw(m).rounded_rectangle((0,0,w-1,h-1),radius=int(w*0.13),fill=255)
    fr.paste(im,(b,b),m); return fr
def shadow(img):
    s=Image.new('RGBA',(img.width+120,img.height+120),(0,0,0,0))
    s.paste((0,0,0,255),(60,80),img.split()[3].point(lambda v:150 if v else 0)); return s.filter(ImageFilter.GaussianBlur(30))
cv=bg.convert('RGBA')
for name,cx,y,rot in [('glass-container',985,170,-6),('app-icon',1435,170,6),('media-controls',1210,95,0)]:
    p=phone(f'{R}/screenshots/components/{name}.jpg',250); sh=shadow(p)
    if rot: p=p.rotate(rot,resample=Image.BICUBIC,expand=True); sh=sh.rotate(rot,resample=Image.BICUBIC,expand=True)
    cv.alpha_composite(sh,(cx-sh.width//2,y-40)); cv.alpha_composite(p,(cx-p.width//2,y))
ov=Image.new('RGBA',(W,H),(0,0,0,0)); od=ImageDraw.Draw(ov); d=ImageDraw.Draw(cv)
d.text((90,215),'glassy_ui_ios',font=font(92),fill=(255,255,255))
d.text((94,335),'90 native iOS components for Flutter',font=font(40,'Semibold'),fill=(225,225,245))
d.text((94,392),'Real SwiftUI & UIKit · Liquid Glass on iOS 26+',font=font(30,'Regular'),fill=(185,185,215))
x=94; f=font(24,'Semibold'); labels=['SwiftUI','Liquid Glass','iOS 17+','SPM']
for lb in labels:
    w=d.textlength(lb,font=f); od.rounded_rectangle((x,480,x+w+40,528),radius=24,fill=(255,255,255,36),outline=(255,255,255,110),width=2); x+=w+56
cv.alpha_composite(ov); d=ImageDraw.Draw(cv); x=94
for lb in labels:
    w=d.textlength(lb,font=f); d.text((x+20,488),lb,font=f,fill=(255,255,255)); x+=w+56
d.text((94,600),'flutter pub add glassy_ui_ios',font=font(26,'Regular','/System/Library/Fonts/SFNSMono.ttf'),fill=(160,200,255))
cv.convert('RGB').save(f'{R}/screenshots/banner.png',optimize=True)

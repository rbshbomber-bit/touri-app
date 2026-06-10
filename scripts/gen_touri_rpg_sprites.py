"""
32x32 도트 토우리 RPG sprite 생성.
- 4방향 (down, up, right) × 4프레임 = 12장
- left는 게임 엔진에서 right를 flipX로 처리 (sprite 안 만듦)
- 32x32 → 4배 NEAREST 업스케일 → 128x128 저장 (FilterQuality.none로 표시)

출력: assets/character/rpg_sprites/touri_{dir}_{frame}.png
"""

from PIL import Image
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "character" / "rpg_sprites"
OUT_DIR.mkdir(parents=True, exist_ok=True)

W, H, SCALE = 32, 32, 4

# 토우리 팔레트 (DS급 32-bit 그라데이션 느낌)
WHITE = (255, 250, 252, 255)
LILAC_EAR = (230, 207, 240, 255)
PINK_EAR = (248, 213, 221, 255)
EYE = (42, 26, 31, 255)
EYE_HI = (255, 255, 255, 255)
BLUSH = (251, 203, 211, 255)
MOUTH = (232, 155, 170, 255)
OUTLINE = (75, 50, 57, 255)
SHADOW = (200, 175, 185, 255)
NONE = (0, 0, 0, 0)


def canvas():
    return Image.new("RGBA", (W, H), NONE)


def rect(img, x, y, w, h, color):
    for dx in range(w):
        for dy in range(h):
            if 0 <= x + dx < W and 0 <= y + dy < H:
                img.putpixel((x + dx, y + dy), color)


def px(img, x, y, color):
    if 0 <= x < W and 0 <= y < H:
        img.putpixel((x, y), color)


def outline_rect(img, x, y, w, h, color):
    for dx in range(w):
        px(img, x + dx, y, color)
        px(img, x + dx, y + h - 1, color)
    for dy in range(h):
        px(img, x, y + dy, color)
        px(img, x + w - 1, y + dy, color)


def head_outline(img, x, y, w, h):
    """둥근 모서리 머리"""
    outline_rect(img, x, y, w, h, OUTLINE)
    # 모서리 둥글게 — 4귀퉁이 픽셀 지움
    px(img, x, y, NONE)
    px(img, x + w - 1, y, NONE)
    px(img, x, y + h - 1, NONE)
    px(img, x + w - 1, y + h - 1, NONE)


# ────────────────────────────────────────
# DOWN (정면) — 토우리 얼굴
# ────────────────────────────────────────
def draw_down(frame):
    img = canvas()
    # 귀 (왼/오)
    rect(img, 6, 2, 4, 8, LILAC_EAR)
    rect(img, 7, 4, 2, 5, PINK_EAR)
    rect(img, 22, 2, 4, 8, LILAC_EAR)
    rect(img, 23, 4, 2, 5, PINK_EAR)
    outline_rect(img, 6, 2, 4, 8, OUTLINE)
    outline_rect(img, 22, 2, 4, 8, OUTLINE)
    # 머리
    rect(img, 8, 6, 16, 12, WHITE)
    head_outline(img, 7, 5, 18, 14)
    # 머리 그림자 (아래쪽 살짝)
    for x in range(9, 23):
        px(img, x, 17, SHADOW)
    # 눈
    rect(img, 12, 11, 2, 3, EYE)
    rect(img, 18, 11, 2, 3, EYE)
    px(img, 12, 11, EYE_HI)
    px(img, 18, 11, EYE_HI)
    # 볼
    px(img, 10, 14, BLUSH); px(img, 11, 14, BLUSH)
    px(img, 20, 14, BLUSH); px(img, 21, 14, BLUSH)
    px(img, 10, 15, BLUSH); px(img, 21, 15, BLUSH)
    # 입 (작은 v)
    px(img, 15, 15, MOUTH); px(img, 16, 15, MOUTH)
    px(img, 14, 15, MOUTH); px(img, 17, 15, MOUTH)
    # 몸
    rect(img, 11, 19, 10, 6, WHITE)
    outline_rect(img, 10, 18, 12, 8, OUTLINE)
    # 몸 그림자
    for x in range(11, 21):
        px(img, x, 24, SHADOW)
    # 발 (걸음 애니메이션)
    if frame == 0 or frame == 2:
        rect(img, 12, 26, 3, 3, OUTLINE)
        rect(img, 17, 26, 3, 3, OUTLINE)
    elif frame == 1:
        rect(img, 12, 25, 3, 3, OUTLINE)
        rect(img, 17, 26, 3, 3, OUTLINE)
    else:
        rect(img, 12, 26, 3, 3, OUTLINE)
        rect(img, 17, 25, 3, 3, OUTLINE)
    return img


# ────────────────────────────────────────
# UP (뒷모습)
# ────────────────────────────────────────
def draw_up(frame):
    img = canvas()
    # 귀 (뒤에서 보면 살짝 작게)
    rect(img, 7, 2, 3, 7, LILAC_EAR)
    rect(img, 22, 2, 3, 7, LILAC_EAR)
    outline_rect(img, 7, 2, 3, 7, OUTLINE)
    outline_rect(img, 22, 2, 3, 7, OUTLINE)
    # 뒷통수
    rect(img, 8, 6, 16, 12, WHITE)
    head_outline(img, 7, 5, 18, 14)
    # 뒷통수 솜털 (분홍 점)
    px(img, 15, 9, BLUSH); px(img, 16, 9, BLUSH)
    px(img, 14, 10, BLUSH); px(img, 17, 10, BLUSH)
    # 머리 그림자
    for x in range(9, 23):
        px(img, x, 17, SHADOW)
    # 몸
    rect(img, 11, 19, 10, 6, WHITE)
    outline_rect(img, 10, 18, 12, 8, OUTLINE)
    for x in range(11, 21):
        px(img, x, 24, SHADOW)
    # 발 (걸음)
    if frame == 0 or frame == 2:
        rect(img, 12, 26, 3, 3, OUTLINE)
        rect(img, 17, 26, 3, 3, OUTLINE)
    elif frame == 1:
        rect(img, 12, 26, 3, 3, OUTLINE)
        rect(img, 17, 25, 3, 3, OUTLINE)
    else:
        rect(img, 12, 25, 3, 3, OUTLINE)
        rect(img, 17, 26, 3, 3, OUTLINE)
    return img


# ────────────────────────────────────────
# RIGHT (옆) — left는 게임에서 flipX
# ────────────────────────────────────────
def draw_right(frame):
    img = canvas()
    # 앞귀 (오른쪽 방향이니 오른쪽 귀가 앞)
    rect(img, 17, 2, 4, 8, LILAC_EAR)
    rect(img, 18, 4, 2, 5, PINK_EAR)
    outline_rect(img, 17, 2, 4, 8, OUTLINE)
    # 뒷귀 (살짝 보임)
    rect(img, 11, 3, 3, 6, LILAC_EAR)
    outline_rect(img, 11, 3, 3, 6, OUTLINE)
    # 머리 (옆에서 보면 더 동그란 느낌)
    rect(img, 9, 6, 14, 12, WHITE)
    head_outline(img, 8, 5, 16, 14)
    # 그림자
    for x in range(9, 23):
        px(img, x, 17, SHADOW)
    # 눈 (앞쪽 1개만)
    rect(img, 18, 11, 2, 3, EYE)
    px(img, 18, 11, EYE_HI)
    # 볼 (앞쪽)
    px(img, 20, 14, BLUSH); px(img, 21, 14, BLUSH)
    px(img, 21, 15, BLUSH)
    # 코끝/입 (앞쪽 살짝 튀어나옴)
    px(img, 22, 13, MOUTH); px(img, 23, 13, MOUTH)
    px(img, 22, 14, MOUTH)
    # 몸 (옆)
    rect(img, 11, 19, 11, 6, WHITE)
    outline_rect(img, 10, 18, 13, 8, OUTLINE)
    for x in range(11, 22):
        px(img, x, 24, SHADOW)
    # 발 (옆에서 보면 앞뒤로)
    if frame == 0 or frame == 2:
        rect(img, 12, 26, 3, 3, OUTLINE)
        rect(img, 17, 26, 3, 3, OUTLINE)
    elif frame == 1:
        # 뒷발 앞으로
        rect(img, 11, 26, 3, 3, OUTLINE)
        rect(img, 18, 26, 3, 3, OUTLINE)
    else:
        rect(img, 14, 26, 3, 3, OUTLINE)
        rect(img, 16, 26, 3, 3, OUTLINE)
    return img


def save_upscaled(img, name):
    big = img.resize((W * SCALE, H * SCALE), Image.NEAREST)
    big.save(OUT_DIR / name)
    print(f"  ✓ {name}")


def main():
    print(f"도트 토우리 RPG sprite 생성 → {OUT_DIR}\n")
    for f in range(4):
        save_upscaled(draw_down(f), f"touri_down_{f + 1}.png")
    for f in range(4):
        save_upscaled(draw_up(f), f"touri_up_{f + 1}.png")
    for f in range(4):
        save_upscaled(draw_right(f), f"touri_right_{f + 1}.png")
    print(f"\n✓ 12장 저장 완료. left는 게임에서 right flipX로 처리.")


if __name__ == "__main__":
    main()

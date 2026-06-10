"""
친구 토우리 (stage 3) 액션 5종 × 4프레임 = 20 sprite 생성.

idle  — 가만히 + 눈 깜박
walk  — 걸음 (RPG sprite 재사용 가능)
eat   — 입 벌리고 음식 받기
jump  — 다리 모으고 점프
happy — 양손 들고 춤추기

64x64 PNG. FilterQuality.none로 도트 그대로.
출력: assets/character/actions/friend/{action}_{1-4}.png
"""

from PIL import Image
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "character" / "actions" / "friend"
OUT_DIR.mkdir(parents=True, exist_ok=True)

W, H, SCALE = 32, 32, 2  # 64x64 출력 (게임 화면에 맞게 크게)

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

# 음식 (딸기) 컬러
STRAWBERRY = (229, 77, 111, 255)
STRAW_SEED = (255, 224, 102, 255)
STRAW_LEAF = (143, 174, 94, 255)


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
    outline_rect(img, x, y, w, h, OUTLINE)
    px(img, x, y, NONE)
    px(img, x + w - 1, y, NONE)
    px(img, x, y + h - 1, NONE)
    px(img, x + w - 1, y + h - 1, NONE)


def draw_right_ear_floppy(img, yo=0):
    """🐰 토우리 시그니처 — 오른쪽 귀가 옆으로 누움 (처짐).
    정수리 우측에서 시작 → 옆으로 누우면서 끝에 살짝 둥근 모양."""
    # 본체 (가로 직사각형 — 옆으로 누움)
    rect(img, 21, 4 + yo, 6, 3, LILAC_EAR)
    # 끝부분 살짝 올라간 둥근 부분
    rect(img, 25, 3 + yo, 2, 4, LILAC_EAR)
    # 안쪽 분홍 (가로 따라)
    rect(img, 22, 5 + yo, 4, 1, PINK_EAR)
    px(img, 26, 4 + yo, PINK_EAR)
    # outline
    outline_rect(img, 21, 4 + yo, 6, 3, OUTLINE)
    outline_rect(img, 25, 3 + yo, 2, 4, OUTLINE)


def draw_base_head(img, eye_closed=False, mouth_open=False, blush_extra=False, y_offset=0):
    """공통 머리 — 정면 토우리 얼굴 (왼쪽 귀 위로, 오른쪽 귀 옆으로 처짐 = 시그니처)"""
    yo = y_offset
    # 왼쪽 귀 (위로 솟음)
    rect(img, 6, 2 + yo, 4, 8, LILAC_EAR)
    rect(img, 7, 4 + yo, 2, 5, PINK_EAR)
    outline_rect(img, 6, 2 + yo, 4, 8, OUTLINE)
    # 오른쪽 귀 — 처짐 (시그니처)
    draw_right_ear_floppy(img, yo)
    # 머리
    rect(img, 8, 6 + yo, 16, 12, WHITE)
    head_outline(img, 7, 5 + yo, 18, 14)
    for x in range(9, 23):
        px(img, x, 17 + yo, SHADOW)
    # 눈
    if eye_closed:
        # 눈 감기 (가로선)
        rect(img, 12, 12 + yo, 2, 1, EYE)
        rect(img, 18, 12 + yo, 2, 1, EYE)
    else:
        rect(img, 12, 11 + yo, 2, 3, EYE)
        rect(img, 18, 11 + yo, 2, 3, EYE)
        px(img, 12, 11 + yo, EYE_HI)
        px(img, 18, 11 + yo, EYE_HI)
    # 볼
    px(img, 10, 14 + yo, BLUSH); px(img, 11, 14 + yo, BLUSH)
    px(img, 20, 14 + yo, BLUSH); px(img, 21, 14 + yo, BLUSH)
    if blush_extra:
        px(img, 10, 15 + yo, BLUSH); px(img, 21, 15 + yo, BLUSH)
        px(img, 9, 14 + yo, BLUSH); px(img, 22, 14 + yo, BLUSH)
    # 입
    if mouth_open:
        rect(img, 14, 15 + yo, 4, 2, MOUTH)
        px(img, 15, 16 + yo, EYE)  # 입 안 어둡게
    else:
        px(img, 15, 15 + yo, MOUTH); px(img, 16, 15 + yo, MOUTH)
        px(img, 14, 15 + yo, MOUTH); px(img, 17, 15 + yo, MOUTH)


def draw_base_body(img, y_offset=0):
    yo = y_offset
    rect(img, 11, 19 + yo, 10, 6, WHITE)
    outline_rect(img, 10, 18 + yo, 12, 8, OUTLINE)
    for x in range(11, 21):
        px(img, x, 24 + yo, SHADOW)


def draw_feet_standard(img, frame, y_offset=0):
    yo = y_offset
    if frame == 0 or frame == 2:
        rect(img, 12, 26 + yo, 3, 3, OUTLINE)
        rect(img, 17, 26 + yo, 3, 3, OUTLINE)
    elif frame == 1:
        rect(img, 12, 25 + yo, 3, 3, OUTLINE)
        rect(img, 17, 26 + yo, 3, 3, OUTLINE)
    else:
        rect(img, 12, 26 + yo, 3, 3, OUTLINE)
        rect(img, 17, 25 + yo, 3, 3, OUTLINE)


# ──────────────────────────────────────
# 1. IDLE — 가만히 + 눈 깜박 (f3에서)
# ──────────────────────────────────────
def draw_idle(frame):
    img = canvas()
    # frame 3에서만 눈 깜박
    eye_closed = (frame == 3)
    draw_base_head(img, eye_closed=eye_closed)
    draw_base_body(img)
    # 발 standard
    rect(img, 12, 26, 3, 3, OUTLINE)
    rect(img, 17, 26, 3, 3, OUTLINE)
    return img


# ──────────────────────────────────────
# 2. WALK — 4프레임 걸음
# ──────────────────────────────────────
def draw_walk(frame):
    img = canvas()
    draw_base_head(img)
    draw_base_body(img)
    draw_feet_standard(img, frame)
    return img


# ──────────────────────────────────────
# 3. EAT — 입 벌리고 음식 받기
# ──────────────────────────────────────
def draw_eat(frame):
    img = canvas()
    # frame 0: 입 살짝, 음식 멀리
    # frame 1: 입 더 벌림, 음식 가까이
    # frame 2: 입 크게, 음식 입 앞
    # frame 3: 입 다물고, 음식 사라짐 (먹음)
    mouth_open = (frame >= 1 and frame <= 2)
    blush = (frame == 2 or frame == 3)
    draw_base_head(img, mouth_open=mouth_open, blush_extra=blush)
    draw_base_body(img)
    rect(img, 12, 26, 3, 3, OUTLINE)
    rect(img, 17, 26, 3, 3, OUTLINE)
    # 딸기 (frame에 따라 위치)
    if frame == 0:
        # 멀리 (오른쪽 위)
        rect(img, 27, 12, 3, 4, STRAWBERRY)
        px(img, 28, 11, STRAW_LEAF)
    elif frame == 1:
        # 가까이
        rect(img, 24, 14, 3, 4, STRAWBERRY)
        px(img, 25, 13, STRAW_LEAF)
    elif frame == 2:
        # 입 앞
        rect(img, 19, 16, 3, 3, STRAWBERRY)
        px(img, 19, 15, STRAW_LEAF)
    # frame 3 = 딸기 사라짐 (먹음)
    return img


# ──────────────────────────────────────
# 4. JUMP — 다리 모으고 점프
# ──────────────────────────────────────
def draw_jump(frame):
    img = canvas()
    # frame 0: 살짝 웅크림 (preparation)
    # frame 1: 점프! (위로) 다리 모음
    # frame 2: 최고점 (눈 반짝)
    # frame 3: 착지 (살짝 웅크림)
    if frame == 0:
        # 웅크림
        draw_base_head(img, y_offset=2)
        draw_base_body(img, y_offset=2)
        # 다리 짧게
        rect(img, 12, 28, 3, 2, OUTLINE)
        rect(img, 17, 28, 3, 2, OUTLINE)
    elif frame == 1:
        # 점프 시작 (위로)
        draw_base_head(img, y_offset=-3, blush_extra=True)
        draw_base_body(img, y_offset=-3)
        # 다리 모음 (가운데)
        rect(img, 14, 24, 4, 3, OUTLINE)
    elif frame == 2:
        # 최고점 (눈 더 반짝)
        draw_base_head(img, y_offset=-5, blush_extra=True)
        # 빛 (별)
        for (xs, ys) in [(4, 4), (28, 6), (5, 16), (28, 18)]:
            px(img, xs, ys, BLUSH)
            px(img, xs + 1, ys, BLUSH)
            px(img, xs, ys + 1, BLUSH)
        draw_base_body(img, y_offset=-5)
        rect(img, 14, 22, 4, 3, OUTLINE)
    else:  # frame 3
        # 착지
        draw_base_head(img, y_offset=1)
        draw_base_body(img, y_offset=1)
        rect(img, 11, 27, 3, 3, OUTLINE)
        rect(img, 18, 27, 3, 3, OUTLINE)
    return img


# ──────────────────────────────────────
# 5. HAPPY — 양손 들고 춤
# ──────────────────────────────────────
def draw_happy(frame):
    img = canvas()
    draw_base_head(img, blush_extra=True)
    # 몸 + 양손 들기
    rect(img, 11, 19, 10, 6, WHITE)
    outline_rect(img, 10, 18, 12, 8, OUTLINE)
    # 손 (양옆)
    if frame == 0 or frame == 2:
        # 위로
        rect(img, 7, 17, 3, 4, WHITE)
        outline_rect(img, 7, 17, 3, 4, OUTLINE)
        rect(img, 22, 17, 3, 4, WHITE)
        outline_rect(img, 22, 17, 3, 4, OUTLINE)
    else:
        # 더 위로 (frame 1, 3)
        rect(img, 7, 14, 3, 4, WHITE)
        outline_rect(img, 7, 14, 3, 4, OUTLINE)
        rect(img, 22, 14, 3, 4, WHITE)
        outline_rect(img, 22, 14, 3, 4, OUTLINE)
        # 양손 위 반짝
        px(img, 8, 12, BLUSH); px(img, 23, 12, BLUSH)
    # 발 살짝 점프 (좌우 교차)
    if frame % 2 == 0:
        rect(img, 12, 26, 3, 3, OUTLINE)
        rect(img, 17, 25, 3, 3, OUTLINE)
    else:
        rect(img, 12, 25, 3, 3, OUTLINE)
        rect(img, 17, 26, 3, 3, OUTLINE)
    # 음표 (선택)
    if frame == 1:
        px(img, 26, 8, OUTLINE); px(img, 27, 8, OUTLINE)
        px(img, 27, 7, OUTLINE); px(img, 27, 6, OUTLINE)
    if frame == 3:
        px(img, 4, 8, OUTLINE); px(img, 5, 8, OUTLINE)
        px(img, 5, 7, OUTLINE); px(img, 5, 6, OUTLINE)
    return img


# ──────────────────────────────────────
# 6. SLEEP — 누움 + Zz
# ──────────────────────────────────────
def draw_sleep(frame):
    img = canvas()
    # 누운 자세 — y 아래로
    # 머리 (옆으로 살짝)
    rect(img, 6, 14, 4, 6, LILAC_EAR)  # 귀 옆으로
    rect(img, 7, 16, 2, 3, PINK_EAR)
    outline_rect(img, 6, 14, 4, 6, OUTLINE)
    rect(img, 8, 18, 12, 8, WHITE)  # 머리 옆으로 누움
    head_outline(img, 7, 17, 14, 10)
    # 눈 (감김)
    rect(img, 10, 22, 2, 1, EYE)
    rect(img, 14, 22, 2, 1, EYE)
    # 입 (Zz)
    px(img, 11, 24, MOUTH)
    # 몸 (누움)
    rect(img, 18, 22, 8, 4, WHITE)
    outline_rect(img, 17, 21, 10, 6, OUTLINE)
    # 발 (옆)
    rect(img, 24, 26, 3, 2, OUTLINE)
    rect(img, 20, 26, 3, 2, OUTLINE)
    # Zz 표시 (frame에 따라 크기)
    zz_y = 4 + frame  # 위로 떠오름
    if frame >= 1:
        # Z 작은 거
        rect(img, 22, zz_y, 3, 1, OUTLINE)
        px(img, 24, zz_y + 1, OUTLINE)
        px(img, 23, zz_y + 2, OUTLINE)
        px(img, 22, zz_y + 3, OUTLINE)
        rect(img, 22, zz_y + 3, 3, 1, OUTLINE)
    if frame >= 2:
        # Z 더 큰 거
        rect(img, 26, zz_y - 2, 4, 1, OUTLINE)
        px(img, 28, zz_y - 1, OUTLINE)
        px(img, 27, zz_y, OUTLINE)
        px(img, 26, zz_y + 1, OUTLINE)
        rect(img, 26, zz_y + 1, 4, 1, OUTLINE)
    return img


# ──────────────────────────────────────
# 7. SURPRISE — 눈 크게 + 손 들기
# ──────────────────────────────────────
def draw_surprise(frame):
    img = canvas()
    yo = -1 if frame == 1 else 0  # 살짝 점프
    # 왼쪽 귀 (놀라서 더 위로)
    rect(img, 6, 1 + yo, 4, 9, LILAC_EAR)
    rect(img, 7, 3 + yo, 2, 6, PINK_EAR)
    outline_rect(img, 6, 1 + yo, 4, 9, OUTLINE)
    # 오른쪽 귀 — 처짐 (시그니처)
    draw_right_ear_floppy(img, yo)
    # 머리
    rect(img, 8, 6 + yo, 16, 12, WHITE)
    head_outline(img, 7, 5 + yo, 18, 14)
    # 눈 (큰)
    rect(img, 11, 10 + yo, 3, 4, EYE)
    rect(img, 18, 10 + yo, 3, 4, EYE)
    px(img, 12, 11 + yo, EYE_HI)
    px(img, 19, 11 + yo, EYE_HI)
    # 입 (O)
    rect(img, 14, 15 + yo, 4, 3, MOUTH)
    rect(img, 15, 16 + yo, 2, 1, EYE)
    # 몸 + 손 들기
    rect(img, 11, 19 + yo, 10, 6, WHITE)
    outline_rect(img, 10, 18 + yo, 12, 8, OUTLINE)
    # 양손 위로
    rect(img, 7, 15 + yo, 3, 4, WHITE)
    outline_rect(img, 7, 15 + yo, 3, 4, OUTLINE)
    rect(img, 22, 15 + yo, 3, 4, WHITE)
    outline_rect(img, 22, 15 + yo, 3, 4, OUTLINE)
    # 발
    rect(img, 12, 26 + yo, 3, 3, OUTLINE)
    rect(img, 17, 26 + yo, 3, 3, OUTLINE)
    # 머리 위 ! (frame 2)
    if frame == 2:
        rect(img, 15, 1, 2, 4, OUTLINE)
        rect(img, 15, 6, 2, 1, OUTLINE)
    # 별 (frame 0)
    if frame == 0:
        px(img, 4, 5, BLUSH); px(img, 28, 5, BLUSH)
    return img


# ──────────────────────────────────────
# 8. SAD — 눈물 + 머리 숙임
# ──────────────────────────────────────
def draw_sad(frame):
    img = canvas()
    yo = 1  # 머리 살짝 숙임
    # 왼쪽 귀 (슬퍼서 살짝 처짐)
    rect(img, 6, 3 + yo, 4, 8, LILAC_EAR)
    outline_rect(img, 6, 3 + yo, 4, 8, OUTLINE)
    # 오른쪽 귀 — 더 처짐 (시그니처)
    draw_right_ear_floppy(img, yo + 1)
    # 머리
    rect(img, 8, 7 + yo, 16, 12, WHITE)
    head_outline(img, 7, 6 + yo, 18, 14)
    # 눈 (반쯤 감김 + 슬픔)
    rect(img, 12, 12 + yo, 2, 2, EYE)
    rect(img, 18, 12 + yo, 2, 2, EYE)
    # 입 (slight frown)
    rect(img, 14, 17 + yo, 4, 1, MOUTH)
    px(img, 13, 16 + yo, MOUTH)
    px(img, 18, 16 + yo, MOUTH)
    # 눈물 (frame >= 1)
    blue_tear = (108, 169, 200, 255)
    if frame >= 1:
        rect(img, 11, 15 + yo, 1, 2, blue_tear)
    if frame >= 2:
        rect(img, 11, 15 + yo, 1, 3, blue_tear)
        rect(img, 20, 15 + yo, 1, 2, blue_tear)
    # 몸
    rect(img, 11, 20 + yo, 10, 6, WHITE)
    outline_rect(img, 10, 19 + yo, 12, 8, OUTLINE)
    # 발
    rect(img, 12, 27, 3, 2, OUTLINE)
    rect(img, 17, 27, 3, 2, OUTLINE)
    return img


# ──────────────────────────────────────
# 9. WAVE — 한손 흔들기 (인사)
# ──────────────────────────────────────
def draw_wave(frame):
    img = canvas()
    draw_base_head(img, blush_extra=True)
    rect(img, 11, 19, 10, 6, WHITE)
    outline_rect(img, 10, 18, 12, 8, OUTLINE)
    # 왼손 (고정)
    rect(img, 7, 19, 3, 4, WHITE)
    outline_rect(img, 7, 19, 3, 4, OUTLINE)
    # 오른손 (흔들림)
    if frame == 0:
        rect(img, 22, 16, 3, 4, WHITE)
        outline_rect(img, 22, 16, 3, 4, OUTLINE)
    elif frame == 1:
        rect(img, 24, 13, 3, 4, WHITE)
        outline_rect(img, 24, 13, 3, 4, OUTLINE)
        # 손 위 별
        px(img, 26, 10, BLUSH); px(img, 27, 10, BLUSH)
    elif frame == 2:
        rect(img, 25, 11, 3, 4, WHITE)
        outline_rect(img, 25, 11, 3, 4, OUTLINE)
        px(img, 28, 9, BLUSH)
    else:  # frame 3
        rect(img, 23, 14, 3, 4, WHITE)
        outline_rect(img, 23, 14, 3, 4, OUTLINE)
    # 발
    rect(img, 12, 26, 3, 3, OUTLINE)
    rect(img, 17, 26, 3, 3, OUTLINE)
    return img


# ──────────────────────────────────────
# 10. DANCE — 양손 + 발 리듬
# ──────────────────────────────────────
def draw_dance(frame):
    img = canvas()
    draw_base_head(img, blush_extra=True)
    rect(img, 11, 19, 10, 6, WHITE)
    outline_rect(img, 10, 18, 12, 8, OUTLINE)
    # 손 (좌우 교차)
    if frame == 0:
        # 왼손 위, 오른손 아래
        rect(img, 7, 14, 3, 4, WHITE)
        outline_rect(img, 7, 14, 3, 4, OUTLINE)
        rect(img, 22, 20, 3, 4, WHITE)
        outline_rect(img, 22, 20, 3, 4, OUTLINE)
    elif frame == 1:
        # 양손 옆
        rect(img, 5, 18, 4, 4, WHITE)
        outline_rect(img, 5, 18, 4, 4, OUTLINE)
        rect(img, 23, 18, 4, 4, WHITE)
        outline_rect(img, 23, 18, 4, 4, OUTLINE)
    elif frame == 2:
        # 오른손 위, 왼손 아래
        rect(img, 22, 14, 3, 4, WHITE)
        outline_rect(img, 22, 14, 3, 4, OUTLINE)
        rect(img, 7, 20, 3, 4, WHITE)
        outline_rect(img, 7, 20, 3, 4, OUTLINE)
    else:  # frame 3
        # 양손 위 (점프 절정)
        rect(img, 7, 12, 3, 4, WHITE)
        outline_rect(img, 7, 12, 3, 4, OUTLINE)
        rect(img, 22, 12, 3, 4, WHITE)
        outline_rect(img, 22, 12, 3, 4, OUTLINE)
        # 양손 위 음표
        px(img, 8, 9, OUTLINE); px(img, 23, 9, OUTLINE)
    # 발 좌우 흔들림
    if frame % 2 == 0:
        rect(img, 11, 26, 3, 3, OUTLINE)
        rect(img, 18, 26, 3, 3, OUTLINE)
    else:
        rect(img, 13, 26, 3, 3, OUTLINE)
        rect(img, 16, 26, 3, 3, OUTLINE)
    # 음표 (어디든)
    if frame == 1:
        px(img, 28, 6, OUTLINE); px(img, 29, 6, OUTLINE)
        px(img, 29, 5, OUTLINE); px(img, 29, 4, OUTLINE)
    return img


def save_upscaled(img, name):
    big = img.resize((W * SCALE, H * SCALE), Image.NEAREST)
    big.save(OUT_DIR / name)
    print(f"  ✓ {name}")


def main():
    print(f"친구 토우리 액션 sprite 생성 → {OUT_DIR}\n")
    actions = {
        'idle': draw_idle,
        'walk': draw_walk,
        'eat': draw_eat,
        'jump': draw_jump,
        'happy': draw_happy,
        'sleep': draw_sleep,
        'surprise': draw_surprise,
        'sad': draw_sad,
        'wave': draw_wave,
        'dance': draw_dance,
    }
    for action_name, drawer in actions.items():
        for f in range(4):
            save_upscaled(drawer(f), f"{action_name}_{f + 1}.png")
    print(f"\n✓ {len(actions)} 액션 × 4 frame = {len(actions) * 4}장 저장 완료.")


if __name__ == "__main__":
    main()

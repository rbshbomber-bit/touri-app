#!/usr/bin/env python3
"""Regenerate core Touri app assets in the blended pink watercolor theme."""

from __future__ import annotations

import argparse
import os
import random
import sys
import urllib.request
from dataclasses import dataclass
from pathlib import Path

try:
    import fal_client
    from dotenv import load_dotenv
except ImportError:
    print("pip install fal-client python-dotenv")
    sys.exit(1)


ROOT = Path(__file__).resolve().parent.parent
ASSET_ROOT = ROOT / "assets" / "character"
LORA_URL_FILE = ROOT / "touri_lora_url.txt"

STYLE = (
    "soft watercolor illustration, warm cream pink ambient wash, pastel pink and lilac palette, "
    "the bunny and background feel painted in the same watercolor layer, "
    "soft pink reflected light on bunny edges, gentle cream-pink contact shadows, "
    "shared watercolor paper texture across character and background, low contrast cocoa lineart, "
    "no harsh cutout edge, no isolated sticker look, centered composition, square crop"
)

TOURI = (
    "touri-bunny, cute kawaii white fluffy bunny, tiny black dot eyes, pink blush cheeks, "
    "sweet smile, viewer-left ear standing up tall, viewer-right ear flopping down sideways, "
    "signature asymmetrical droopy ear, do not make both ears upright, do not make both ears droop"
)

NEGATIVE = (
    "text, letters, words, korean, hangul, english, japanese, chinese, alphabet, numbers, digits, "
    "glyphs, pseudo text, fake writing, scribbles, captions, titles, labels, banners, signs, "
    "speech bubbles, thought bubbles, callouts, watermarks, logos, signatures, typography, "
    "artist signature, tiny signature, corner signature, tiny corner mark, initials, "
    "paper with writing, book text, newspaper text, UI elements, buttons, app screenshots, "
    "white rectangle, white patch, foggy overpaint, harsh white background, sticker cutout, "
    "decorative marks that look like text, wall writing, object writing, tiny black marks, "
    "black square, black background, transparent background, multiple characters, "
    "photorealistic, 3d render, blurry, low quality"
)


@dataclass(frozen=True)
class AssetPrompt:
    path: str
    scene: str


ASSETS = [
    # Menu icons currently referenced by lib/screens/menu_screen.dart
    AssetPrompt("menu_icons/diary.png", "cozy diary corner, the bunny writing with a pink strawberry pen in a completely blank open notebook, pink desk mat, soft bedroom light"),
    AssetPrompt("menu_icons/pet_growth_v2.png", "cozy bedroom pet-care corner, the bunny sitting on a heart-shaped rug with a pink pillow behind, warm cream-pink room"),
    AssetPrompt("menu_icons/village.png", "cherry blossom village, the bunny walking on a cobblestone path, pink-roof cottage behind, falling sakura petals"),
    AssetPrompt("menu_icons/generate.png", "cozy art desk, the bunny holding a magic pink paintbrush, soft lilac sparkles blending into the warm pink room"),
    AssetPrompt("menu_icons/sticker_make.png", "simple craft table scene, the bunny holding a plain pink heart sticker, only a few pastel craft tools nearby, plain empty cream wall, no wall decor"),
    AssetPrompt("menu_icons/collection.png", "treasure shelf scene, the bunny opening a pastel pink keepsake box, warm pink glow and tiny hearts blending into the room"),
    AssetPrompt("menu_icons/season_pack.png", "cozy seasonal display, the bunny beside four simple seasonal objects on a plain pink rug: cherry blossom petal, sunflower, maple leaf, rose, plain empty cream wall"),
    AssetPrompt("menu_icons/coaching.png", "warm coaching nook, the bunny cheering gently with one paw raised, small heart cushion and soft lamp behind, plain empty cream wall"),
    AssetPrompt("menu_icons/spirituality.png", "calm meditation room, the bunny meditating on a pink cushion, crescent moon decor and lilac aura softly blended"),
    AssetPrompt("menu_icons/news.png", "morning reading nook, the bunny holding a completely blank folded pink paper, coffee mug beside, warm pink light"),
    AssetPrompt("menu_icons/settings.png", "organized bedroom shelf, the bunny wearing round pastel glasses and holding a small pink key, simple gear-shaped decor with no markings"),

    # Home/news thumbnails
    AssetPrompt("news_categories/life.png", "cozy life corner, the bunny holding a heart-shaped mug on a pink rug, candle and flower behind"),
    AssetPrompt("news_categories/manifest.png", "manifestation room, the bunny reaching toward a glowing pink star above a soft pillow, warm pink aura"),
    AssetPrompt("news_categories/it.png", "soft tech desk, the bunny tapping a small pink tablet with a completely blank screen, pixel hearts as abstract decor"),
    AssetPrompt("news_categories/spirituality.png", "moonlit meditation corner, the bunny sitting on a pink cushion with a clear crystal, simple crescent moon shape above, lilac-pink glow, plain empty cream wall"),
    AssetPrompt("news_categories/culture.png", "cozy culture nook, the bunny hugging a completely blank pastel book, small curtain-like pink fabric in background"),
    AssetPrompt("news_categories/economy.png", "warm savings corner, the bunny hugging a plain heart-shaped coin pillow, simple pink rug, plain empty cream wall, no real coins, no piggy bank"),
    AssetPrompt("news_categories/society.png", "community room scene, the bunny holding a heart cushion, two small plain empty chairs nearby, plain empty cream wall, warm welcoming mood"),
    AssetPrompt("news_categories/sports.png", "soft exercise corner, the bunny doing a gentle stretch on a plain pink rug, one plain pink dumbbell nearby, plain empty cream wall, no headband"),
    AssetPrompt("news_categories/business.png", "neat work nook, the bunny with a tiny bow tie beside a plain brown briefcase, laptop closed with no logo"),
    AssetPrompt("news_categories/education.png", "study room, the bunny wearing a tiny graduation cap and holding a completely blank rolled diploma"),
    AssetPrompt("news_categories/politics.png", "gentle leadership room, the bunny standing beside a small plain podium with no writing, soft starburst light"),
    AssetPrompt("news_categories/love.png", "romantic pink bedroom corner, the bunny hugging a heart pillow, rose petals softly falling"),

    # Empty states
    AssetPrompt("empty_states/empty_diary.png", "quiet diary desk, the bunny holding a tiny pen and looking at a completely blank notebook with totally blank pages, plain empty cream wall, inviting expression"),
    AssetPrompt("empty_states/empty_collection.png", "empty keepsake shelf, the bunny peeking into an empty pastel pink treasure box, hopeful tiny sparkle"),
    AssetPrompt("empty_states/empty_news.png", "peaceful resting room, the bunny napping on a plain folded pink blanket, plain empty cream wall, no newspaper, no letters, no sleep symbols"),
    AssetPrompt("empty_states/empty_stickers.png", "craft corner, the bunny holding a completely blank sticker sheet, hopeful eyes, soft pink supplies around"),
    AssetPrompt("empty_states/quota_exceeded.png", "dreamy room, the bunny reaching toward a glowing pink star just out of reach, hopeful expression"),
    AssetPrompt("empty_states/error.png", "cozy repair corner, the bunny holding an unplugged pink cable, confused gentle face, no question mark or text"),

    # Pet static stages
    AssetPrompt("pet/stardust.png", "abstract soft pink and lilac stardust particles gathering into a very faint bunny-ear glow on a cream-pink bedroom backdrop, no face, no complete body"),
    AssetPrompt("pet/baby.png", "tiny baby Touri sitting on a pink heart rug in a cozy bedroom, extra small round body, shy smile"),
    AssetPrompt("pet/friend.png", "standard friend-stage Touri sitting confidently on a soft pink rug in a cozy bedroom, gentle smile"),
    AssetPrompt("pet/sparkle.png", "sparkle-stage Touri floating slightly above a pink rug, soft lilac aura blended with bedroom light, peaceful closed eyes"),
    AssetPrompt("pet/master.png", "master-stage Touri wearing a tiny golden crown with heart jewel, sitting regally on a pink rug, soft golden halo blended into warm pink room, plain empty cream wall"),
]


def prompt_for(asset: AssetPrompt) -> str:
    return f"{TOURI}, {asset.scene}, {STYLE}, no text"


def load_lora_url() -> str:
    if not LORA_URL_FILE.exists():
        print(f"Missing {LORA_URL_FILE}")
        sys.exit(1)
    return LORA_URL_FILE.read_text().strip()


def generate(asset: AssetPrompt, lora_url: str, out_root: Path, overwrite: bool) -> Path:
    out = out_root / asset.path
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists() and not overwrite:
        print(f"skip {asset.path}")
        return out

    seed = random.randint(1, 2_147_483_647)
    print(f"generate {asset.path} seed={seed}", flush=True)
    result = fal_client.run(
        "fal-ai/flux-lora",
        arguments={
            "prompt": prompt_for(asset),
            "negative_prompt": NEGATIVE,
            "loras": [{"path": lora_url, "scale": 0.9}],
            "num_inference_steps": 34,
            "guidance_scale": 4.8,
            "num_images": 1,
            "image_size": "square_hd",
            "seed": seed,
            "enable_safety_checker": True,
        },
    )
    urllib.request.urlretrieve(result["images"][0]["url"], out)
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--only", nargs="*", help="Generate only matching asset paths.")
    parser.add_argument("--out", default="assets/character/theme_refresh", help="Output root.")
    parser.add_argument("--overwrite", action="store_true")
    args = parser.parse_args()

    load_dotenv(ROOT / ".env")
    if not os.getenv("FAL_KEY"):
        print("Missing FAL_KEY")
        sys.exit(1)

    lora_url = load_lora_url()
    out_root = ROOT / args.out
    selected = ASSETS
    if args.only:
      wanted = set(args.only)
      selected = [asset for asset in ASSETS if asset.path in wanted or any(w in asset.path for w in wanted)]

    print(f"Generating {len(selected)} assets -> {out_root.relative_to(ROOT)}")
    for asset in selected:
        generate(asset, lora_url, out_root, args.overwrite)
    print("done")


if __name__ == "__main__":
    main()

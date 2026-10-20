const REQUIREMENTS={
  "checked_at": "2026-10-18T07:12:27.482Z",
  "scope": "assets only; no new gameplay screens",
  "notion_status": "Original page refreshed and read through CUA connection to signed-in Notion app; Notion MCP connector returned 404.",
  "sources": [
    "design/planning/notion-source-2026-10-18.json",
    "PRODUCT.md",
    "design/planning/stages-2026-10-18.md",
    "images/drinks/README.md",
    "ui/drinks.json",
    "README.md",
    "ui/search_glow.svg",
    "ui/reward_halo.svg",
    "ui/crying_icon.svg"
  ],
  "notes": [
    "Assets only. Existing art masters are preserved; this review changes the requirements and source records.",
    "5x3 is the visual display grid. Independently, the newly verified first-stage allocation lists 15 drinks; the current code still has 9.",
    "Do not create consume/use inventory assets: successful purchases apply ability immediately.",
    "The original contains proposals and unresolved rules; do not bake numeric values into sprite images.",
    "Eight overall gold values do not require eight drawings; reuse one coin with editable value text. First-stage probability proposal uses 1, 5, 10, 50 Gold and miss.",
    "Reuse the selected Arcade Pop direction: 8 names match existing art directly, Fanta needs grape-flavour validation, and 6 drinks need new art.",
    "Proposed regional layouts, material-to-region mappings, coffee and ice cream remain unconfirmed.",
    "No map stage numbering or region connection lines. This does not delete existing skill-tree connectors.",
    "Discount, higher-denomination chance and automatic material-drop chance are excluded from this drink-option allocation; this is not a global deletion of other progression systems."
  ],
  "items": [
    {
      "id": "currency",
      "priority": "P0",
      "asset": "골드 보상 표시",
      "scope": "전체 골드 8단위; 첫 스테이지 발견 확률안은 1 / 5 / 10 / 50 Gold + 꽝",
      "quantity": "공통 동전 1종 + 금액 텍스트 8값",
      "status": "금액 규칙 확정 · 개별 금액 아트 8종은 미확정",
      "basis": "PRODUCT.md; design/planning/notion-source-2026-10-18.json",
      "reuse": "기존 동전과 편집 가능한 금액 텍스트 재사용",
      "motion_notes": "등장·튕김·이동은 엔진 변환. 금액마다 PNG를 별도로 만들 필요 없음"
    },
    {
      "id": "drinks",
      "priority": "P0",
      "asset": "첫 스테이지 음료 15종",
      "scope": "물 / 녹차 / 보리차 / 이온 / 사과 / 진저에일 / 레모네이드 / 스프라이트 / 복숭아 / 오렌지 / 비타민 / 멜론 소다 / 환타 포도 / 콜라 / 에너지",
      "quantity": "배정안 15종 = 기존 8종 재사용 + 환타 포도 검수 1종 + 신규 6종",
      "status": "원문 최신 배정안 · 코드 9종과 분리",
      "basis": "design/planning/notion-source-2026-10-18.json; PRODUCT.md Latest Planning Review; images/drinks/README.md; ui/drinks.json",
      "reuse": "Arcade Pop 기존 9종 중 8종 우선 재사용, 환타는 포도맛 일치 검수",
      "motion_notes": "신규: 보리차·진저에일·레모네이드·복숭아·멜론 소다·에너지. 효과 문구·수치는 편집 텍스트로 관리"
    },
    {
      "id": "vending-parts",
      "priority": "P0",
      "asset": "자판기 B 부품 분리",
      "scope": "외장 / 3단 진열 배경 / 음료 슬롯 / 선택 버튼 / 결제부 / 배출구",
      "quantity": "세부 분리 수량 설계 필요",
      "status": "정적 B 완성 · 부품은 통합 PNG",
      "basis": "Penpot B 비교 요청; PRODUCT.md",
      "reuse": "기존 정면 5×3 B의 형태 유지",
      "motion_notes": "피버 타격을 위해 본체·고정 그림자·점등부·배출구를 분리. 흔들림·플래시는 엔진 변환; 기계 전체 프레임을 중복 제작하지 않음"
    },
    {
      "id": "vending-states",
      "priority": "P0",
      "asset": "수동 자판기 반응 상태",
      "scope": "대기 / 선택 강조 / 동전 투입 / 배출 / 성공 / 꽝",
      "quantity": "상태 목록 · 프레임 수 미정",
      "status": "플레이 흐름 필요 · 연출 방식 제안",
      "basis": "PRODUCT.md",
      "reuse": "외장·결제부·배출구 공통 재사용",
      "motion_notes": "점등·약한 흔들림은 추가 그림 없이 처리; 배출구 열린 상태 등 형상 변화만 별도"
    },
    {
      "id": "feedback",
      "priority": "P0",
      "asset": "수색·보상·꽝 FX",
      "scope": "바닥 수색 밝기 / 금액 팝업 / 획득 강조 / 꽝 아이콘",
      "quantity": "공통 FX 세트",
      "status": "부분 있음 · 현재 구현 재사용 후보",
      "basis": "PRODUCT.md; README.md; ui/search_glow.svg; ui/reward_halo.svg; ui/crying_icon.svg",
      "reuse": "기존 glow·halo·crying 아이콘과 반짝임 재사용",
      "motion_notes": "알파·색·이동으로 연출. 수색 보상과 꽝은 새 배정안 참조, 기존 구매 꽝 설명은 별도 충돌 기록. 골드 2배와 진행도 2회 효과는 서로 구분"
    },
    {
      "id": "button-states",
      "priority": "P0",
      "asset": "공통 UI 컴포넌트 상태",
      "scope": "기본 / 포커스 / 누름 / 비활성",
      "quantity": "현재 5종 UI의 상태 확장",
      "status": "기본 상태 있음 · 인터랙션 제작 제안",
      "basis": "현재 에셋 라이브러리; Steam PC 우선",
      "reuse": "재화·구매·강화·해금·일시정지 기본 컴포넌트",
      "motion_notes": "문구·숫자는 편집 가능한 텍스트로 유지"
    },
    {
      "id": "drink-effect-icons",
      "priority": "P0",
      "asset": "15종 음료 능력 표식",
      "scope": "고정 골드 / 비율 골드 / 골드 2배 확률 / 꽝 감소 / 클릭 2회 인정 / 일반·펀치 시간 / 클릭 감소 / 피버 해금·발동",
      "quantity": "10개 의미 · 공통 도형 조합, 실제 신규 이미지 수 미정",
      "status": "최신 배정안 근거 · 시각 표현 제안",
      "basis": "design/planning/notion-source-2026-10-18.json; PRODUCT.md Latest Planning Review",
      "reuse": "동전·커서·시계·반짝임 공통 아이콘과 편집 텍스트",
      "motion_notes": "골드×2와 클릭 진행도×2를 서로 다른 표식으로 표현. 삭제된 할인·고액 동전 확률·자동 드롭 확률은 이번 음료용 아이콘에서 제외"
    },
    {
      "id": "search-fever",
      "priority": "P0",
      "asset": "수색 피버 FX",
      "scope": "진입 / 활성 바닥 클릭 / 강화 보상 / 종료",
      "quantity": "공통 FX 세트 · 프레임 수 미정",
      "status": "원문 피버 기능 추가 · 연출 상태는 제안",
      "basis": "design/planning/notion-source-2026-10-18.json; PRODUCT.md Latest Planning Review",
      "reuse": "기존 수색 glow·spark·reward halo를 확장",
      "motion_notes": "바닥 클릭 위치의 짧은 강조·발광·보상 숫자 변화를 엔진 처리. 수색·일반·일반 클릭 피버 명칭 대응과 구체 발동 조건은 미정"
    },
    {
      "id": "punch-fever",
      "priority": "P0",
      "asset": "펀치 피버·타격 FX",
      "scope": "주먹 커서 / 타격 표시 / 본체 반동·플래시 / 타격 골드 / 종료",
      "quantity": "타격 피드백 세트 · 프레임 수 미정",
      "status": "원문 펀치 기능 추가 · 그림·모션은 미제작",
      "basis": "design/planning/notion-source-2026-10-18.json; PRODUCT.md Latest Planning Review",
      "reuse": "자판기 B 부품·동전·획득 FX 공통 활용",
      "motion_notes": "일시적인 본체 타격 동작을 바닥 수색과 구분. 주먹·충격만 추가하고 본체 이동은 엔진 처리. 에너지 5초·재발동·타격 보상은 제안/미정"
    },
    {
      "id": "fever-status",
      "priority": "P0",
      "asset": "피버 상태·시간 컴포넌트",
      "scope": "미해금 / 사용 가능 / 활성 / 종료; 일반·펀치 또는 특수 모드 식별",
      "quantity": "공통 상태 배지·시간 바 · 제안",
      "status": "신규 피버를 위한 에셋 구성 제안",
      "basis": "design/planning/notion-source-2026-10-18.json; PRODUCT.md Latest Planning Review",
      "reuse": "기존 버튼 포커스·비활성 상태, 편집 가능한 시간 텍스트",
      "motion_notes": "기존 사이드 패널 없이 독립 컴포넌트로 관리. 오렌지의 시간 증가 대상과 30초·5초 상한 충돌 해결 전 숫자를 아트에 굽지 않음"
    },
    {
      "id": "mastery-cap",
      "priority": "P2",
      "asset": "강화 한도·반복 획득 표식",
      "scope": "현재/최대 강화 / 한도 도달 / 빈캔 획득 / 에너지 재발동 안내",
      "quantity": "공통 배지 세트 · 규칙 확정 후",
      "status": "강화 한도 이후 동작은 원문 제안 · 제작 보류",
      "basis": "design/planning/notion-source-2026-10-18.json; PRODUCT.md Latest Planning Review",
      "reuse": "상품 그림·빈캔·공통 레벨 텍스트",
      "motion_notes": "강화 한도 뒤 빈캔만 지급과 에너지 반복 발동은 미확정. 제안값을 고정된 완료 화면이나 효과 수치로 만들지 않음"
    },
    {
      "id": "automation",
      "priority": "P1",
      "asset": "자동 자판기 식별·상태",
      "scope": "가동 중 / 생산 대기 / 보상 준비 / 생산 완료",
      "quantity": "베이스 1종 + 상태 · 수량 미정",
      "status": "기능 확정 · 현재 별도 전용 외형 없음",
      "basis": "PRODUCT.md",
      "reuse": "수동 자판기 베이스 일부와 상태 표시 재사용",
      "motion_notes": "자동 획득 물품은 능력 구매 성공으로 표시하지 않음"
    },
    {
      "id": "trash",
      "priority": "P1",
      "asset": "쓰레기통 반응",
      "scope": "대기 / 투입구 또는 뚜껑 열림 / 자동 회수 강조",
      "quantity": "정적 기본 있음 · 상태 미제작",
      "status": "자동 회수 기능 확정",
      "basis": "PRODUCT.md",
      "reuse": "현재 기본 쓰레기통 재사용",
      "motion_notes": "흡입·물품 이동은 엔진 연출, 실제 바뀌는 뚜껑만 추가 그림"
    },
    {
      "id": "drop-lifecycle",
      "priority": "P1",
      "asset": "필드 드롭 생명주기",
      "scope": "생성 / 바닥 회수 대기 / 소멸 / 직접 회수 / 쓰레기통 자동 회수",
      "quantity": "동전·재료 공통 상태 세트 · 프레임 수 미정",
      "status": "직접 회수·시간 경과 소멸·확률 자동 회수 규칙 확정; 시각 연출 제안",
      "basis": "PRODUCT.md Operating Context; Capabilities and Constraints",
      "reuse": "동전·빈캔·추가 재료 아이콘 및 획득 FX 공통 활용",
      "motion_notes": "생성 시 튕김, 대기 강조, 소멸 점멸·페이드, HUD 또는 쓰레기통으로 이동은 엔진 제안. 확률 자동 회수로 능력은 증가하지 않음. 소멸 시간·수치는 미정"
    },
    {
      "id": "materials",
      "priority": "P1",
      "asset": "해금 재료 아이콘",
      "scope": "빈캔 / 빈 용기 / 폐지 / 빈 캡슐 / 피자 상자",
      "quantity": "기획안 5계열 · 빈캔 외 4계열 미제작",
      "status": "빈캔 확정 · 상품별 세부 매핑은 제안",
      "basis": "PRODUCT.md; design/planning/stages-2026-10-18.md",
      "reuse": "현재 빈캔 아이콘·컴포넌트 활용",
      "motion_notes": "회수 가능·소멸 임박은 같은 아이콘의 강조와 점멸로 처리"
    },
    {
      "id": "machine-ramen",
      "priority": "P1",
      "asset": "라멘 자판기",
      "scope": "음식 메뉴·조리 또는 보온부·용기 배출구",
      "quantity": "기본 외형 1종부터",
      "status": "추가 방향 확정 · 외형 미제작",
      "basis": "PRODUCT.md; design/planning/stages-2026-10-18.md",
      "reuse": "정면 카메라·픽셀 밀도·외곽선 기준 공유",
      "motion_notes": "같은 빨간 음료 자판기의 색만 바꾸지 않고 구조 차이 표현"
    },
    {
      "id": "machine-magazine",
      "priority": "P1",
      "asset": "잡지 자판기",
      "scope": "잡지 표지 진열·넓은 상품 투출구",
      "quantity": "기본 외형 1종부터",
      "status": "추가 방향 확정 · 외형 미제작",
      "basis": "PRODUCT.md; design/planning/stages-2026-10-18.md",
      "reuse": "공통 버튼·동전 투입부 재사용",
      "motion_notes": "표지와 본체 분리"
    },
    {
      "id": "machine-figure",
      "priority": "P1",
      "asset": "피규어 자판기",
      "scope": "피규어 또는 캡슐 진열·상품 배출부",
      "quantity": "기본 외형 1종부터",
      "status": "추가 방향 확정 · 외형 미제작",
      "basis": "PRODUCT.md; design/planning/stages-2026-10-18.md",
      "reuse": "공통 외곽선·결제부 재사용",
      "motion_notes": "빈 캡슐 재화 지급 방식은 확정 전"
    },
    {
      "id": "machine-pizza",
      "priority": "P1",
      "asset": "피자 자판기",
      "scope": "메뉴 사진·가열 또는 조리 표시·상자 배출구",
      "quantity": "기본 외형 1종부터",
      "status": "추가 방향 확정 · 외형 미제작",
      "basis": "PRODUCT.md; design/planning/stages-2026-10-18.md",
      "reuse": "공통 결제부·UI 재사용",
      "motion_notes": "상품과 피자 상자 재료 표현 구분"
    },
    {
      "id": "product-families",
      "priority": "P1",
      "asset": "비음료 상품 그림",
      "scope": "라멘 / 잡지 / 피규어 / 피자",
      "quantity": "4계열 · 상품별 종류 수 미정",
      "status": "계열 확정 · 세부 상품과 능력 미정",
      "basis": "PRODUCT.md",
      "reuse": "상품 그림을 획득·능력 목록·스킬 노드에 재사용",
      "motion_notes": "별도 음료 사용·보관·소모품 퀵슬롯 에셋은 만들지 않음"
    },
    {
      "id": "skill-icons",
      "priority": "P1",
      "asset": "능력·강화 아이콘",
      "scope": "골드 금액 / 상위 골드 확률 / 클릭 수 / 생산 시간 / 생산량 / 자동 회수 확률",
      "quantity": "6개 의미의 공통 아이콘 제안",
      "status": "능력 범주 근거 있음 · 아이콘 제작 미완료",
      "basis": "PRODUCT.md",
      "reuse": "상품 그림·동전·빈캔과 조합",
      "motion_notes": "일반 성장·자동화 범주용. 고액 동전 확률 증가를 이번 15종 음료 능력으로 추가하지 않음; 신규 음료 능력 표식은 별도 항목"
    },
    {
      "id": "regions",
      "priority": "P2",
      "asset": "지역 배경 확장",
      "scope": "주차장 / 아키하바라 / 온천 / 상업지구 / 고급 주택가(가칭) / 도쿄타워",
      "quantity": "7지역 검토안을 따르면 골목 외 6종",
      "status": "도쿄타워 추가 결정 · 나머지 구성과 명칭은 기획안",
      "basis": "design/planning/stages-2026-10-18.md",
      "reuse": "현재 일본풍 골목길 1종 있음",
      "motion_notes": "지역별 정면 설치 벽·바닥 수색 영역 확보; 이번에는 새 지도 이미지 제작 안 함"
    },
    {
      "id": "region-thumbnails",
      "priority": "P2",
      "asset": "지역 선택 대표 이미지",
      "scope": "지역별 풍경의 작은 대표 썸네일",
      "quantity": "지역 수에 맞춤 · 확정 전",
      "status": "독립 지역 선택 방식 확정",
      "basis": "design/planning/stages-2026-10-18.md",
      "reuse": "지역 배경에서 파생해 중복 제작 줄임",
      "motion_notes": "지도에 스테이지 번호·연결선을 넣지 않음"
    },
    {
      "id": "unlock-markers",
      "priority": "P1",
      "asset": "지역·자판기 해금 표식",
      "scope": "지역 잠금과 자판기 잠금을 구분: 잠김 / 해금 가능 / 해금됨 / 선택됨 / 재료 부족",
      "quantity": "공통 표식 세트",
      "status": "상태 필요 · 표현 제안",
      "basis": "PRODUCT.md; design/planning/stages-2026-10-18.md",
      "reuse": "자물쇠·체크·재료 아이콘 조합",
      "motion_notes": "빈캔은 주차장 음료 자판기 하나만 해금. 지역 입장과 개별 자판기 해금 상세 규칙·나머지 재화 매핑은 미정"
    },
    {
      "id": "regional-skins",
      "priority": "P2",
      "asset": "지역별 상품·기계 변형",
      "scope": "기념 캔·프리미엄 상품·지역 특색",
      "quantity": "수량 미정 · 범위 확정 후",
      "status": "검토 제안 · 일괄 제작 보류",
      "basis": "design/planning/stages-2026-10-18.md",
      "reuse": "기본 5계열을 재사용하고 필요한 변형만 추가",
      "motion_notes": "7지역×모든 자판기 조합을 의무 제작하지 않음"
    },
    {
      "id": "optional-machines",
      "priority": "P3",
      "asset": "커피·아이스크림",
      "scope": "본체 / 상품 / 빈 컵·막대",
      "quantity": "추가 채택 후 산정",
      "status": "미확정 제안 · 제작 보류",
      "basis": "design/planning/stages-2026-10-18.md",
      "reuse": "추가 여부 확정 전 생성하지 않음",
      "motion_notes": "추천 항목을 확정된 게임 요구로 취급하지 않음"
    },
    {
      "id": "audio",
      "priority": "P2",
      "asset": "효과음·환경음",
      "scope": "동전 획득·투입 / 배출 / 성공·꽝 / 해금 / 자동 회수 / 골목 환경음",
      "quantity": "사운드 이벤트 목록 · 수량 미정",
      "status": "비주얼 외 제작 제안",
      "basis": "클릭·구매·자동 회수 흐름에 따른 제작 제안",
      "reuse": "같은 이벤트를 반복할 때 변형 음량·피치 활용 가능",
      "motion_notes": "기획 확정 사양이나 이번 이미지 산출물에 포함된 것으로 보고하지 않음"
    }
  ],
  "source_review": {
    "notion": {
      "url": "https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de",
      "result": "Updated original body verified after refresh in signed-in Notion app",
      "method": "CUA connection to signed-in Notion app; refreshed original page; connected Notion MCP returned 404",
      "snapshot": "design/planning/notion-source-2026-10-18.json",
      "checked_at": "2026-10-18T07:12:27.482Z",
      "credentials_omitted": true
    },
    "local": [
      {
        "path": "design/planning/notion-source-2026-10-18.json",
        "modified_at": "2026-10-18T16:12:27+09:00",
        "sha256": "404a807f14c44984fd2122d05cd437d6dac99c85fbc3a76453835ea18c379b06"
      },
      {
        "path": "PRODUCT.md",
        "modified_at": "2026-10-18T16:13:30+09:00",
        "sha256": "e5317f573d9e3b597b12e5bada86a0a88a9adb6ba86e81787961ca08233d4055"
      },
      {
        "path": "design/planning/stages-2026-10-18.md",
        "modified_at": "2026-10-18T15:21:38+09:00",
        "sha256": "17b034e643516c06b35de37cca5806a8e2da07ad02ece5a899cea0666475f304"
      },
      {
        "path": "images/drinks/README.md",
        "modified_at": "2026-10-18T15:21:38+09:00",
        "sha256": "6294ef31a2e9aa68f441d9a0a0449b5b941071bf400ecbd9a12a610fdf2611fc"
      },
      {
        "path": "ui/drinks.json",
        "modified_at": "2026-10-18T15:21:38+09:00",
        "sha256": "fae381bc8bd0c137adb633ebf4f6eb25fee8c7b2b283dc35bfea97f9b7b61de1"
      },
      {
        "path": "README.md",
        "modified_at": "2026-10-18T15:24:05+09:00",
        "sha256": "53af8ab2808a7c7c27c8f5fdad6f4a3f597f6504211a93bf72396e2c32b08f44"
      },
      {
        "path": "ui/search_glow.svg",
        "modified_at": "2026-10-18T15:21:38+09:00",
        "sha256": "ee15729b76db7ae7bb10e423cd98ad66e0c8d4cad70e66bfdf019280be8a1e1f"
      },
      {
        "path": "ui/reward_halo.svg",
        "modified_at": "2026-10-18T15:21:38+09:00",
        "sha256": "e43c909dbf5d8089fb19193fe32483b3834b3b9be598f740b705c349d25502b6"
      },
      {
        "path": "ui/crying_icon.svg",
        "modified_at": "2026-10-18T15:21:38+09:00",
        "sha256": "8d61d9f601e989aa499ef05640b26bf38249c4a1afdee01b1818e32c0d6a9f5e"
      }
    ],
    "interpretation": "New first-stage 15-drink allocation and fever sections verified in original. Allocation proposals, exact values, unresolved rules and recorded local stage decisions stay distinct."
  },
  "open_questions": [
    {
      "topic": "피버 시간 배정 불일치",
      "source_table": "복숭아는 일반 피버 / 오렌지는 펀치 피버 시간 증가",
      "source_aggregate": "복숭아·오렌지 합산으로 일반 피버 최대 30초, 특수 피버는 최대 5초 별도 유지 제안",
      "action": "서로 다른 피버의 아이콘·시간 상태를 분리하되 합산·상한 수치를 고정하지 않는다."
    },
    {
      "topic": "피버 명칭·발동·중복",
      "source": "수색 피버 / 일반 피버 / 일반 클릭 피버 / 펀치 피버 / 특수 피버 표현 혼재",
      "action": "명칭 대응, 일반 피버 발동 조건·효과량, 펀치·특수 동일 여부, 중복·갱신 규칙 확인 필요."
    },
    {
      "topic": "구매·수색 꽝과 상품 능력",
      "source": "기존 본문은 구매 꽝·콜라 클릭 감소, 새 배정안은 수색 꽝·콜라 피버 해금; 구현도 9종의 기존 효과 유지",
      "action": "최신 배정안을 별도로 기록한다. 코드·기존 확정 기록을 임의 변경하지 않으며 수치·효과 텍스트는 편집형으로 유지."
    },
    {
      "topic": "강화 한도 이후",
      "source": "추가 강화 없이 빈캔 1개 지급, 에너지 반복 획득 발동은 제안; 소수점 처리는 미정",
      "action": "한도·반복 획득 표시는 컴포넌트 제안으로 보류하며 최종 규칙으로 단정하지 않는다."
    },
    {
      "topic": "지역 입장과 기계 해금",
      "source": "지역 상세·해금 재화 매핑은 로컬 기획의 제안, 빈캔 대상은 주차장 음료 자판기 하나",
      "action": "지역 잠금과 기계 잠금 대상 이름·재료를 구분한다."
    }
  ],
  "first_stage_drinks": [
    {
      "order": 1,
      "id": "water",
      "name": "물",
      "effect": "발견 골드 +1",
      "upgrade_limit": "10회",
      "max_effect": "+10 Gold",
      "art_action": "reuse",
      "existing_art": "images/drinks/water_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 2,
      "id": "green-tea",
      "name": "녹차",
      "effect": "발견 골드 +3",
      "upgrade_limit": "10회",
      "max_effect": "+30 Gold",
      "art_action": "reuse",
      "existing_art": "images/drinks/green_tea_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 3,
      "id": "barley-tea",
      "name": "보리차",
      "effect": "발견 골드 +5",
      "upgrade_limit": "10회",
      "max_effect": "+50 Gold",
      "art_action": "new",
      "existing_art": null,
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 4,
      "id": "ion",
      "name": "이온음료",
      "effect": "최종 발견 골드 +1%",
      "upgrade_limit": "5회",
      "max_effect": "+5%",
      "art_action": "reuse",
      "existing_art": "images/drinks/ion_drink_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 5,
      "id": "apple",
      "name": "사과 주스",
      "effect": "최종 발견 골드 +2%",
      "upgrade_limit": "5회",
      "max_effect": "+10%",
      "art_action": "reuse",
      "existing_art": "images/drinks/apple_juice_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 6,
      "id": "ginger-ale",
      "name": "진저에일",
      "effect": "발견 골드 2배 확률 +0.2%p",
      "upgrade_limit": "10회",
      "max_effect": "발동 확률 2%",
      "art_action": "new",
      "existing_art": null,
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 7,
      "id": "lemonade",
      "name": "레모네이드",
      "effect": "꽝 확률 감소",
      "upgrade_limit": "3회",
      "max_effect": "15% → 10%",
      "art_action": "new",
      "existing_art": null,
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 8,
      "id": "sprite",
      "name": "스프라이트",
      "effect": "클릭 2회 인정 확률 +8%p",
      "upgrade_limit": "10회",
      "max_effect": "80%",
      "art_action": "reuse",
      "existing_art": "images/drinks/sprite_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 9,
      "id": "peach",
      "name": "복숭아 주스",
      "effect": "일반 피버 시간 +1초",
      "upgrade_limit": "10회",
      "max_effect": "+10초",
      "art_action": "new",
      "existing_art": null,
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 10,
      "id": "orange",
      "name": "오렌지 주스",
      "effect": "펀치 피버 시간 +1초",
      "upgrade_limit": "10회",
      "max_effect": "+10초",
      "art_action": "reuse",
      "existing_art": "images/drinks/orange_juice_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 11,
      "id": "vitamin",
      "name": "비타민 음료",
      "effect": "필요 수색 클릭 1회 감소",
      "upgrade_limit": "1회",
      "max_effect": "-1회",
      "art_action": "reuse",
      "existing_art": "images/drinks/vitamin_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 12,
      "id": "melon-soda",
      "name": "멜론 소다",
      "effect": "필요 수색 클릭 1회 감소",
      "upgrade_limit": "1회",
      "max_effect": "-1회",
      "art_action": "new",
      "existing_art": null,
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 13,
      "id": "fanta-grape",
      "name": "환타 — 포도맛",
      "effect": "필요 수색 클릭 1회 감소",
      "upgrade_limit": "1회",
      "max_effect": "-1회",
      "art_action": "validate-flavour",
      "existing_art": "images/drinks/fanta_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 14,
      "id": "cola",
      "name": "콜라",
      "effect": "일반 클릭 피버 해금",
      "upgrade_limit": "최초 1회",
      "max_effect": "일반 피버 사용 가능",
      "art_action": "reuse",
      "existing_art": "images/drinks/cola_pop.tres",
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    },
    {
      "order": 15,
      "id": "energy",
      "name": "에너지 드링크",
      "effect": "타격으로 골드를 얻는 특수 피버",
      "upgrade_limit": "반복 획득형 제안",
      "max_effect": "획득 시 5초 발동 제안",
      "art_action": "new",
      "existing_art": null,
      "status": "원문 배정안 · 제안 수치 및 미정 규칙 포함"
    }
  ],
  "first_stage_probability_proposal": [
    {
      "result": "1 Gold",
      "percent": 70
    },
    {
      "result": "5 Gold",
      "percent": 9
    },
    {
      "result": "10 Gold",
      "percent": 5
    },
    {
      "result": "50 Gold",
      "percent": 1
    },
    {
      "result": "꽝",
      "percent": 15
    }
  ]
};
if(penpot.currentFile.id!=='cd444aaf-0d8c-801b-8008-cda246e18650')throw new Error('대상 파일 확인 필요');
const page=penpot.currentFile.pages.find(p=>p.id==='af2aed71-3cfe-80ea-8008-ceaf7492d553');await penpot.openPage(page);
const b=page.getShapeById('d7a10464-8e4d-803c-8008-ceb58be78642');if(!b)throw new Error('기존 제작 목록 보드 확인 필요');
for(const s of [...b.children])s.remove();b.name='추가 에셋 제작 목록 · 기획 검토';b.resize(1900,3400);b.fills=[{fillColor:'#F0F3F0',fillOpacity:1}];
const font=penpot.fonts.all.find(f=>f.name==='Do Hyeon');
function txt(x,y,w,value,size=24,color='#263743',height=100){
 const s=penpot.createText(value);font.applyToText(s,font.variants[0]);s.fontSize=String(size);s.growType='fixed';s.resize(w,height);s.lineHeight='1.3';s.x=b.x+x;s.y=b.y+y;s.fills=[{fillColor:color,fillOpacity:1}];s.name='Spec / '+value.split('\n')[0];b.appendChild(s);return s;
}
function line(y){const r=penpot.createRectangle();r.resize(1780,2);r.x=b.x+60;r.y=b.y+y;r.fills=[{fillColor:'#CCD8D7',fillOpacity:1}];b.appendChild(r);}
txt(60,42,1750,'추가 에셋 제작 목록 · 최신 노션 재검토',42);
txt(60,108,1750,'원문 확인 2026-10-18 · 음료 15종 배정안 / 수색 피버 / 펀치 피버',27);
txt(60,154,1750,'Notion MCP 404 → 로그인된 Notion 앱을 CUA로 새로고침해 확인. 수치·배정안·미정 규칙을 구분.',22,'#687C82');
txt(60,222,100,'우선',24);txt(180,222,330,'제작 묶음',24);txt(530,222,800,'필요한 에셋 / 상태',24);txt(1380,222,450,'현재 상태 / 판단',24);line(272);
const summary=[
 ['P0','골드 보상 표시','전체 8단위 / 첫 스테이지안 1·5·10·50 + 꽝\n공통 동전 + 금액 텍스트 재사용','8개의 별도 그림은 불필요\n첫 스테이지 확률은 배정안'],
 ['P0','첫 스테이지 음료 15종','기존 8종 재사용 + 환타 포도맛 검수\n신규 6종은 아래 목록 참조','Arcade Pop 방향 재사용\n신규 6종은 아직 미제작'],
 ['P0','자판기 B 부품','외장·진열 배경·상품·버튼·점등부·배출구\n타격 시 본체와 고정 그림자를 분리','현재 정적 통합 PNG\n부품 분리·열림 상태 필요'],
 ['P0','기본 반응·UI 상태','투입·배출·성공·꽝 / 포커스·누름·비활성\n기존 glow·halo·아이콘 재사용','숫자·효과는 편집 텍스트\n반동·점멸·이동은 엔진'],
 ['P0','수색 피버 FX','진입 → 바닥 활성 클릭 → 강화 보상 → 종료\n특별한 클릭 효과·수색과 보상 변화','기능 추가 확인\n구체 발동·효과량 미정'],
 ['P0','펀치 피버 FX','주먹 커서·충격 FX·본체 반동·타격 골드\n바닥 수색과 본체 타격을 구분','기능 추가 확인\n타격 보상·중복 규칙 미정'],
 ['P0','능력·피버 상태 표식','골드×2와 클릭 진행도×2를 별도로 표현\n피버 미해금·활성·종료·시간 컴포넌트','일반·펀치 시간 배정 충돌\n30초·5초를 아트에 고정 안 함'],
 ['P1','자동 생산·쓰레기통','가동·대기·보상 준비 / 뚜껑·자동 회수\n수동 자판기·기존 쓰레기통 재사용','기능 확정\n추가 상태 미제작'],
 ['P1','필드 드롭 생명주기','생성 → 회수 대기 → 직접/자동 회수 또는 소멸\n동전·재료 아이콘과 공통 FX 활용','회수·소멸 규칙 확정\n자동 회수로 능력 증가 없음'],
 ['P1','신규 자판기 4계열','라멘 / 잡지 / 피규어 / 피자\n진열·상품 배출 구조 구분','계열 확장 방향 확정\n외형·상품 수 미정'],
 ['P1','상품·해금 재료','비음료 상품 4계열 + 빈캔 외 재료\n빈 용기·폐지·빈 캡슐·피자 상자 후보','상품 계열은 확정\n재료별 지역 매핑은 제안'],
 ['P1','지역·기계 해금 표식','지역 잠금과 개별 기계 잠금을 구분\n빈캔은 주차장 음료 자판기 하나만 해금','독립 지역·자유 이동 결정\n지도 번호·지역 연결선 제외'],
 ['P2','지역·썸네일·한도','도쿄타워 / 7지역 검토안 / 배경 파생 썸네일\n강화 한도·반복 획득 배지는 규칙 확정 후','지역 구성·매핑은 검토안\n새 지도 이미지는 제작 안 함'],
 ['P3','보류·제외','커피·아이스크림은 미확정 / 음원은 추가 제안\n할인·고액 동전 확률·자동 드롭 확률은 음료에서 제외','제외 범위는 이번 음료 옵션\n기존 성장 시스템 전체 삭제 아님']
];
for(let i=0;i<summary.length;i++){
 const [priority,name,scope,status]=summary[i],y=296+i*110;
 txt(60,y,100,priority,26,priority==='P0'?'#A25327':'#376A78');txt(180,y,330,name,26);txt(530,y,800,scope,24);txt(1380,y,450,status,22,'#64777D');line(y+99);
}
const start=1900;
txt(60,start,1750,'첫 스테이지 음료 15종 · 배정안 / 아트 대응',34);
txt(60,start+55,1750,'효과 수치·한도는 PRODUCT.md 및 JSON에 기록. 아래는 아트 제작 판단이며 코드 변경이 아니다.',22,'#64777D');
txt(60,start+112,100,'순서',23);txt(180,start+112,330,'음료',23);txt(530,start+112,800,'배정된 효과',23);txt(1380,start+112,450,'아트 작업',23);line(start+152);
for(let i=0;i<REQUIREMENTS.first_stage_drinks.length;i++){
 const d=REQUIREMENTS.first_stage_drinks[i],y=start+168+i*46;
 const action=d.art_action==='new'?'신규 제작 필요':d.art_action==='validate-flavour'?'기존 환타 → 포도맛 검수':'기존 아트 재사용';
 txt(60,y,100,String(d.order),24,'#263743',40);txt(180,y,330,d.name,24,'#263743',40);txt(530,y,800,d.effect,24,'#263743',40);txt(1380,y,450,action,23,d.art_action==='new'?'#A25327':'#376A78',40);
}
line(2780);
txt(60,2810,1750,'원문 내부 불일치 · 확정 전 수치를 고정하지 않는다',32);
txt(60,2870,1750,'오렌지: 표는 펀치 피버 시간 증가 / 합산 문장은 복숭아와 함께 일반 피버 최대 30초.\n특수 피버 최대 5초 별도 유지 제안도 있어 시간 증가 대상·피버 명칭 대응을 확인해야 한다.',24,'#8E4E2A');
txt(60,2990,1750,'기존 본문은 콜라 클릭 감소 / 최신 배정안은 일반 피버 해금. 기존 구현은 9종의 과거 능력 유지.\n일반 발동 조건·특수 타격 보상·꽝·중복 발동·한도 이후 동작·소수점 처리도 제안 또는 미정.',24);
txt(60,3110,1750,'에셋 전용: 현재 13개 컴포넌트 보존. 신규 음료 6종·피버 FX는 제작 목록이며 완료 아트가 아니다.\n구매 성공 즉시 능력 적용 → 별도 사용·보관 퀵슬롯이나 새 게임 화면은 제작하지 않는다.',24);
txt(60,3260,1750,'전체 27개 제작 묶음·15종 아트 대응·근거·모션·미정 규칙: design/v5/asset-requirements.json / .csv',23,'#64777D');
b.setPluginData('asset-requirements',JSON.stringify(REQUIREMENTS));storage.v5RequirementsBoard=b;
penpot.selection=[b];penpot.viewport.zoomIntoView([b]);
return {page:page.id,requirementsBoard:b.id,entries:REQUIREMENTS.items.length,drinks:REQUIREMENTS.first_stage_drinks.length,components:penpot.library.local.components.length,board:{width:b.width,height:b.height},pages:penpot.currentFile.pages.map(p=>({id:p.id,name:p.name}))};

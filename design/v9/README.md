# 확정 음료 에셋 15종

일반 음료 14종과 황금음료 05 오로라 골드의 승인 결과다. 게임 화면은 포함하지 않는다.

- `exports/`: 192×288 투명 배경 PNG 15개. 공통 하단 기준점으로 배치했다.
- `svg/`: 승인 원본 이미지를 포함한 자체 완결 SVG 15개. 실루엣은 벡터 클립 경로다. 그림과 내부 라벨을 벡터로 재작성한 파일은 아니다.
- `source/`: 승인한 14종 참조 이미지와 05 오로라 골드 원본.
- `items.json`: 이름·파일 키·원본·실루엣 경로·배율.
- `approved-items.png`: 로컬 전체 확인 이미지.
- `trace-masks.js`, `render.js`: 원본 픽셀을 바꾸지 않고 실루엣 경로와 배포 파일을 생성한다.

## Penpot 등록 완료

기존 **02 · 에셋 라이브러리** 안의 **음료 마스터 · 확정 15종** 보드에서 관리한다. 에셋 작업에 새 페이지를 만들지 않는다.

- 파일: `cd444aaf-0d8c-801b-8008-cda246e18650`
- 기존 에셋 페이지: `af2aed71-3cfe-80ea-8008-ceaf7492d553`
- 보드: `e7808af8-2ea3-8077-8008-cedf2d6bd36f`
- 라이브러리 경로: `Clicker/Approved/Drinks`
- 독립 컴포넌트: 15개, 각 192×288. 투명 PNG를 포함하며 이름표는 별도 편집 가능한 텍스트다.
- 배치: 가로 5개 × 세로 3줄.
- 등록 ID와 검증 결과: `penpot-manifest.json`.
- 실제 Penpot 내보내기: `../review/v9/approved-drinks-penpot.png`.

[Penpot에서 열기](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=af2aed71-3cfe-80ea-8008-ceaf7492d553&board-id=e7808af8-2ea3-8077-8008-cedf2d6bd36f&layout=layers)

15개 모두 기존 페이지·대상 보드에 속하고 크기가 192×288인 것을 MCP로 검증했다. 이번 작업 중 잘못 생성한 임시 페이지 2개와 실패한 SVG 불러오기 잔여물 15개를 정리했다. 원래 있던 에셋 보드와 사용자 메모는 보존했다.

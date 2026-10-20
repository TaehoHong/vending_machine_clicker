const expectedFileId = 'cd444aaf-0d8c-801b-8008-cda246e18650';
if (penpot.currentFile?.id !== expectedFileId) throw new Error('Unexpected Penpot file');
const pageName = '00 · 디자인 팔레트(시스템)';
const boardName = '파일 작성 규칙 · 초안 · 2026-10-20';
const existingPage = penpotUtils.getPageByName(pageName);
if (existingPage) throw new Error('Rules page already exists; inspect before updating');
const sourceText = penpotUtils.findShapeById('d7a10464-8e4d-803c-8008-ceb3271745fc');
const sourceBoard = penpotUtils.findShapeById('af2aed71-3cfe-80ea-8008-ceb0d537ce15');
if (!sourceText || !sourceBoard) throw new Error('Documentation style reference missing');
const style = {
  fontId: sourceText.fontId,
  fontFamily: sourceText.fontFamily,
  fontWeight: sourceText.fontWeight,
  fills: sourceText.fills,
  background: sourceBoard.fills
};
const previousPages = penpotUtils.getPages().map(p => ({id:p.id,name:p.name}));
const page = penpot.createPage();
page.name = pageName;
await penpot.openPage(page);
const board = penpot.createBoard();
board.name = boardName;
board.resize(1600, 1900);
board.x = 0;
board.y = 0;
board.fills = style.background;
page.root.appendChild(board);
function label(name, value, x, y, width, size = 28) {
  const text = penpot.createText(value);
  text.name = name;
  text.fontId = style.fontId;
  text.fontFamily = style.fontFamily;
  text.fontWeight = style.fontWeight;
  text.fontSize = String(size);
  text.lineHeight = '1.35';
  text.fills = style.fills;
  text.resize(width, 100);
  text.growType = 'auto-height';
  board.appendChild(text);
  penpotUtils.setParentXY(text, x, y);
  return text;
}
label('문서 / 제목', '디자인 파일 작성 규칙', 64, 46, 1472, 50);
label('문서 / 상태', '초안 · 사용자 제안 00 / 01 / 02 기반 · 2026.10.20', 64, 118, 1472, 26);
label('섹션 / 페이지 구성', '01   기본 페이지 구성', 64, 202, 1472, 34);
const rows = [
  ['00 · 디자인 팔레트(시스템)', '공통 규칙과 UI 원본\n색상 · 글꼴 · 간격 · 테두리 · 버튼/패널 · 상태 · 작성 규칙'],
  ['01 · 게임 화면', '실제 플레이 화면과 화면별 상태\n메인 · 플레이 · 음료와 능력 · 일시정지 · 조작 설명'],
  ['02 · 에셋', '게임 아트 원본과 내보내기 정보\n자판기 · 배경 · 음료 · 재화 · 아이콘 · 커서 · FX 프레임']
];
rows.forEach((row, i) => {
  label('페이지 / '+row[0], row[0], 64, 278+i*124, 478, 28);
  label('역할 / '+row[0], row[1], 560, 278+i*124, 976, 27);
});
label('섹션 / 추가 페이지 검토', '02   추가 페이지 검토', 64, 684, 1472, 34);
label('제안 / 보관함', '99 · 보관함  —  추천 · 미확정', 64, 746, 1472, 28);
label('제안 / 보관함 설명', '이전·미채택·비교 시안을 보존하고 현재 작업과 구분한다.\n상태·모션 설명은 해당 화면 또는 에셋 보드에 두므로 별도 페이지는 지금 필요하지 않다.', 64, 790, 1472, 26);
label('섹션 / 작성 규칙 초안', '03   작성 규칙 초안', 64, 904, 1472, 34);
const rules = [
  ['편집 가능한 원본', 'UI 문구는 Text, 패널·버튼은 편집 가능한 도형으로 만든다. 게임 아트는 이미지 사용이 가능하다.'],
  ['원본을 한곳에서 관리', '공통 UI 원본은 00, 게임 아트 원본은 02에 둔다. 01 화면에서는 연결된 복사본을 사용한다.'],
  ['이름으로 검색 가능하게', '화면·에셋 이름과 상태를 함께 쓴다. 예: 음료와 능력 / 미해금 선택 / PC. svg·Group 같은 이름은 피한다.'],
  ['작업 상태를 명확하게', '검토 중 / 채택 / 이전을 표시한다. 채택 전 시안과 실제 게임 적용 여부를 구분한다.'],
  ['원본과 결과를 함께 검수', '컴포넌트 연결·텍스트 편집·잘림·비율·내보내기를 확인한다. 기획 수치와 동작의 원본은 Notion을 따른다.']
];
rules.forEach((rule, i) => {
  label('규칙 / '+rule[0], String(i+1).padStart(2,'0')+'  '+rule[0], 64, 972+i*112, 1472, 28);
  label('설명 / '+rule[0], rule[1], 112, 1014+i*112, 1424, 25);
});
label('섹션 / 현재 파일 확인', '04   현재 파일에서 확인한 사항', 64, 1564, 1472, 34);
label('근거 / 라이브러리', '작성 전: 기존 페이지 6개 · 컴포넌트 120개 · 등록 색상 0개 · 텍스트 스타일 1개', 64, 1624, 1472, 27);
label('근거 / 편집 구조', '통합 시안의 최상위 그룹 이름이 svg이며, 일부 문구는 Text가 아닌 SVG 원시 도형이다.\n후속 정리에서는 화면별 이름과 편집 가능한 문구를 우선 복원한다.', 64, 1672, 1472, 25);
label('범위 / 다음 결정', '이번 작업: 작성 규칙 초안 추가. 기존 페이지·보드·컴포넌트는 이동·삭제하지 않았다.\n99 보관함 도입과 기존 자료 이동은 구조를 확정한 뒤 진행한다.', 64, 1764, 1472, 25);
storage.clickerAuthoringRules = {fileId:expectedFileId,pageId:page.id,boardId:board.id,previousPages};
penpot.selection = [board];
penpot.viewport.zoomIntoView([board]);
penpot.viewport.zoom = 0.4;
penpot.viewport.center = {x:800,y:950};
return {fileId:expectedFileId,pageId:page.id,pageName:page.name,boardId:board.id,boardName:board.name,editableTexts:penpotUtils.findShapes(s=>s.type==='text',board).length,previousPages};

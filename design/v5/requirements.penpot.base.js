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

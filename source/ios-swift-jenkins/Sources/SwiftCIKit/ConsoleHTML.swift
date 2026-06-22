import Foundation

/// The swiftci web console — a self-contained, dark-themed real-time
/// activity board served by swiftci itself (at `/console`, and at `/`
/// when no static `publicDirectory` is mounted).
///
/// This is the Jenkins-style relationship: swiftci's own HTTP server
/// serves its UI, and a host (e.g. the TinyDashboard) can reverse-proxy
/// it into an iframe. The board reads swiftci's OWN open GET API
/// (`/api/stats`, `/api/builds/recent`, `/api/queue`, `/api/jobs/...`)
/// and resolves in-progress builds client-side from
/// `stats.buildsByJobStatus` (since `/api/builds/recent` is terminal-only).
///
/// All fetches are **base-path-aware**: the page derives its API base from
/// `location.pathname`, so the exact same HTML works when served standalone
/// at `/console` AND when proxied at `/swiftci-proxy/console`. Triggers
/// (`POST /api/jobs/:id/trigger`) need the admin Bearer token — they work
/// when accessed through a proxy that injects it, and 401 gracefully when
/// hit standalone without credentials (the standalone board is a monitor).
public enum SwiftCIConsoleHTML {
    public static let html: String = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Swift CI Console</title>
    <style>
      :root { --bg:#1e1e1e; --panel:#252526; --panel2:#2a2d2e; --border:#3c3c3c;
        --text:#d4d4d4; --muted:#9e9e9e; --accent:#4ec9b0; --blue:#2196f3;
        --green:#4caf50; --red:#f44336; --grey:#757575; --amber:#ff9800; }
      * { box-sizing:border-box; }
      body { margin:0; font-family:'Segoe UI',system-ui,sans-serif; background:var(--bg);
        color:var(--text); font-size:13px; }
      header { display:flex; align-items:center; gap:10px; padding:9px 14px; flex-wrap:wrap;
        border-bottom:1px solid var(--border); background:var(--panel); position:sticky; top:0; z-index:5; }
      header h1 { font-size:15px; margin:0; font-weight:600; }
      header h1 .gear { color:var(--accent); }
      .pill { font-size:11px; padding:2px 8px; border-radius:10px; border:1px solid var(--border); white-space:nowrap; }
      .pill.ok { color:var(--green); border-color:var(--green); }
      .pill.down { color:var(--red); border-color:var(--red); }
      .muted { color:var(--muted); }
      .counts { display:flex; gap:6px; }
      .cnt { font-size:11px; padding:2px 9px; border-radius:10px; border:1px solid var(--border);
        display:flex; align-items:center; gap:5px; }
      .cnt b { font-weight:700; }
      .cnt.run { border-color:var(--blue); color:#90caf9; }
      .cnt.queue { border-color:var(--amber); color:#ffcc80; }
      .cnt.pass { border-color:var(--green); color:#a5d6a7; }
      .cnt.fail { border-color:var(--red); color:#ef9a9a; }
      .dot { width:9px; height:9px; border-radius:50%; display:inline-block; flex:none; }
      .spin { width:10px; height:10px; border-radius:50%; flex:none;
        border:2px solid rgba(33,150,243,.25); border-top-color:var(--blue); animation:sp 0.8s linear infinite; }
      @keyframes sp { to { transform:rotate(360deg); } }
      @keyframes pulse { 0%,100% { opacity:1; } 50% { opacity:.45; } }

      /* Executor strip (Build Executor Status) */
      .execbar { padding:10px 14px; border-bottom:1px solid var(--border); background:var(--panel); }
      .execbar .lbl { font-size:11px; color:var(--muted); text-transform:uppercase; letter-spacing:.5px; margin-bottom:7px; }
      .execs { display:flex; gap:10px; flex-wrap:wrap; }
      .exec { min-width:210px; border:1px solid var(--border); border-radius:8px; padding:9px 11px; background:var(--panel2); }
      .exec.busy { border-color:var(--blue); box-shadow:0 0 0 1px rgba(33,150,243,.25) inset; }
      .exec .top { display:flex; align-items:center; gap:7px; font-weight:600; }
      .exec .sub { font-size:11px; color:var(--muted); margin-top:3px; display:flex; gap:8px; }
      .exec .bar { height:3px; border-radius:2px; background:#333; margin-top:7px; overflow:hidden; }
      .exec .bar i { display:block; height:100%; width:40%; background:var(--blue); animation:slide 1.4s ease-in-out infinite; }
      @keyframes slide { 0% { margin-left:-40%; } 100% { margin-left:100%; } }

      /* Status lanes (kanban) */
      .lanes { display:grid; grid-template-columns:1.2fr 0.9fr 1.4fr; gap:0; min-height:calc(100vh - 230px); }
      .lane { border-right:1px solid var(--border); display:flex; flex-direction:column; min-width:0; }
      .lane:last-child { border-right:none; }
      .lane > .head { padding:9px 12px; font-weight:600; border-bottom:1px solid var(--border);
        display:flex; align-items:center; gap:8px; position:sticky; top:0; background:var(--bg); z-index:2; }
      .lane.run > .head { color:#90caf9; }
      .lane.queue > .head { color:#ffcc80; }
      .lane.recent > .head { color:var(--text); }
      .lane .body { padding:10px; overflow:auto; flex:1; display:flex; flex-direction:column; gap:9px; }
      .card { border:1px solid var(--border); border-radius:8px; padding:10px 11px; background:var(--panel);
        cursor:pointer; transition:border-color .15s; }
      .card:hover { border-color:var(--accent); }
      .card .nm { font-weight:600; display:flex; align-items:center; gap:7px; }
      .card .meta { font-size:11px; color:var(--muted); margin-top:5px; display:flex; gap:10px; align-items:center; }
      .card.running { border-color:var(--blue); }
      .card.running .nm { animation:pulse 1.6s ease-in-out infinite; }
      .lcap { color:var(--blue); font-variant-numeric:tabular-nums; }
      .badge { font-size:10px; padding:1px 7px; border-radius:8px; border:1px solid var(--border); text-transform:uppercase; }
      .badge.passed { color:#a5d6a7; border-color:var(--green); }
      .badge.failed { color:#ef9a9a; border-color:var(--red); }
      .badge.running { color:#90caf9; border-color:var(--blue); }
      .badge.queued { color:#ffcc80; border-color:var(--amber); }
      .badge.canceled { color:#bbb; border-color:var(--grey); }
      .empty { padding:22px 12px; text-align:center; color:var(--muted); font-size:12px; }
      button { background:var(--accent); color:#1e1e1e; border:none; padding:5px 12px;
        border-radius:5px; cursor:pointer; font-weight:600; font-size:12px; }
      button.ghost { background:transparent; color:var(--text); border:1px solid var(--border); font-weight:500; }
      button.mini { padding:2px 9px; font-size:11px; }
      button:disabled { opacity:.45; cursor:default; }

      /* Collapsible job rail */
      .jobspanel { border-top:1px solid var(--border); background:var(--panel); }
      .jobspanel > summary { padding:9px 14px; cursor:pointer; font-weight:600; list-style:none; display:flex; align-items:center; gap:8px; }
      .jobspanel > summary::-webkit-details-marker { display:none; }
      .jobgrid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:8px; padding:0 14px 14px; }
      .jrow { border:1px solid var(--border); border-radius:7px; padding:8px 10px; display:flex; align-items:center; gap:9px; }
      .jrow .nm { font-weight:600; flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
      .jrow .sub { font-size:11px; color:var(--muted); }

      /* Log drawer */
      .drawer { position:fixed; top:0; right:0; width:min(760px,92vw); height:100vh; background:var(--panel);
        border-left:1px solid var(--border); transform:translateX(100%); transition:transform .18s ease;
        z-index:20; display:flex; flex-direction:column; }
      .drawer.open { transform:translateX(0); }
      .drawer .dhead { padding:11px 14px; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:10px; }
      .drawer .builds { display:flex; gap:6px; padding:8px 12px; border-bottom:1px solid var(--border); overflow-x:auto; }
      .bchip { font-size:11px; padding:3px 9px; border-radius:5px; border:1px solid var(--border); cursor:pointer; white-space:nowrap; }
      .bchip.sel { border-color:var(--accent); color:var(--accent); }
      .log { flex:1; overflow:auto; padding:12px 14px; font-family:'Cascadia Code',Consolas,monospace;
        font-size:12px; white-space:pre-wrap; line-height:1.5; }
      .scrim { position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:15; display:none; }
      .scrim.open { display:block; }
    </style>
    </head>
    <body>
    <header>
      <h1><span class="gear">&#9881;</span> Swift CI Console</h1>
      <span id="ver" class="muted"></span>
      <span class="counts">
        <span class="cnt run"><span class="spin"></span><b id="cRun">0</b> running</span>
        <span class="cnt queue">&#9203; <b id="cQueue">0</b> queued</span>
        <span class="cnt pass">&#10003; <b id="cPass">0</b></span>
        <span class="cnt fail">&#10007; <b id="cFail">0</b></span>
      </span>
      <span style="flex:1"></span>
      <span id="health" class="pill">…</span>
      <button class="ghost" onclick="tick(true)">&#8635; Refresh</button>
    </header>

    <div class="execbar">
      <div class="lbl">Executors &mdash; live job executions</div>
      <div class="execs" id="execs"><div class="muted">…</div></div>
    </div>

    <div class="lanes">
      <div class="lane run">
        <div class="head"><span class="spin"></span> Running <span id="hRun" class="muted"></span></div>
        <div class="body" id="laneRun"><div class="empty">Nothing running.</div></div>
      </div>
      <div class="lane queue">
        <div class="head">&#9203; Queued <span id="hQueue" class="muted"></span></div>
        <div class="body" id="laneQueue"><div class="empty">Queue empty.</div></div>
      </div>
      <div class="lane recent">
        <div class="head">&#128338; Recent builds <span id="hRecent" class="muted"></span></div>
        <div class="body" id="laneRecent"><div class="empty">No builds yet.</div></div>
      </div>
    </div>

    <details class="jobspanel" id="jobsPanel">
      <summary>&#129513; Pipelines <span id="jobCount" class="muted"></span> &mdash; click Run to execute</summary>
      <div class="jobgrid" id="jobgrid"><div class="empty">Loading…</div></div>
    </details>

    <div class="scrim" id="scrim" onclick="closeDrawer()"></div>
    <div class="drawer" id="drawer">
      <div class="dhead">
        <strong id="dName">—</strong>
        <span id="dBadge"></span>
        <span style="flex:1"></span>
        <button class="mini" id="dRun" onclick="triggerSel()">&#9654; Run</button>
        <button class="ghost mini" onclick="closeDrawer()">&#10005;</button>
      </div>
      <div class="builds" id="dBuilds"></div>
      <div class="log" id="dLog"><div class="empty">Select a build.</div></div>
    </div>

    <script>
      const SCOL = { passed:'#4caf50', failed:'#f44336', running:'#2196f3',
        queued:'#ff9800', canceled:'#9e9e9e', pending:'#ff9800' };
      let S = { selJob:null, selBuild:null, jobs:[] };

      // Base-aware API. The page derives its base from location.pathname so
      // the SAME html works standalone (served at /console) AND behind a
      // reverse-proxy (served at /swiftci-proxy/console). Computed with
      // string slicing (a regex with escaped slashes is awkward to embed).
      function computeBase(){
        var p = location.pathname;
        if(p.charAt(p.length-1) === '/') p = p.slice(0, -1);
        if(p.slice(-8) === '/console') p = p.slice(0, -8);
        return p;
      }
      const BASE = computeBase();
      function api(p){ return BASE + p; }

      function esc(s){ return String(s).replace(/[&<>"]/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
      function disp(id){ return String(id).replace(/-[0-9a-f]{8}$/i, ''); }
      function dot(c){ return `<span class="dot" style="background:${c||'#757575'}"></span>`; }
      async function jget(u){ try { const r = await fetch(u); if(!r.ok) return null; return await r.json(); } catch { return null; } }
      async function jtext(u){ try { const r = await fetch(u); if(!r.ok) return null; return await r.text(); } catch { return null; } }
      function tsec(iso){ const t = Date.parse(iso); return isNaN(t) ? 0 : Math.floor(t/1000); }
      function fmtDur(s){ if(s<0) s=0; const m=Math.floor(s/60), ss=s%60; return m>0 ? (m+'m '+ss+'s') : (ss+'s'); }
      function elapsed(iso){ const st=tsec(iso); if(!st) return 0; return Math.max(0, Math.floor(Date.now()/1000) - st); }
      function setTxt(id,v){ const e=document.getElementById(id); if(e) e.textContent=v; }

      // swiftci's /api/builds/recent is TERMINAL-only, so resolve the live
      // in-progress builds client-side from stats.buildsByJobStatus: for each
      // job flagged running, read its newest build detail(s) and keep the ones
      // whose status is still "running". Bounded to running-flagged jobs.
      let RUNNING = [];
      async function resolveRunning(stats){
        const byJob = (stats && stats.buildsByJobStatus) || {};
        const out = [];
        for(const jid of Object.keys(byJob)){
          const rc = (byJob[jid] && byJob[jid].running) || 0;
          if(rc < 1) continue;
          const bl = await jget(api('/api/jobs/' + encodeURIComponent(jid) + '/builds'));
          const nums = ((bl && bl.builds) || []).slice().sort((a,b)=>b-a).slice(0, rc+2);
          let found = 0;
          for(const n of nums){
            const d = await jget(api('/api/jobs/' + encodeURIComponent(jid) + '/builds/' + n));
            const b = d && d.build;
            if(b && b.status === 'running'){ out.push(b); found++; if(found>=rc) break; }
          }
        }
        return out.sort((a,b)=> (b.startedAt||'').localeCompare(a.startedAt||''));
      }

      async function tick(force){
        const stats = await jget(api('/api/stats'));
        if(!stats){ return; }
        const bbs = stats.buildsByStatus || {};
        const rec = await jget(api('/api/builds/recent'));
        const recent = (rec && rec.builds) || [];
        const q = await jget(api('/api/queue'));
        const queued = (q && q.builds) || [];
        const running = await resolveRunning(stats);
        RUNNING = running;

        setTxt('cRun', bbs.running||0); setTxt('cQueue', bbs.queued||queued.length||0);
        setTxt('cPass', bbs.passed||0); setTxt('cFail', bbs.failed||0);

        const finished = recent.filter(b => b.status!=='running' && b.status!=='queued')
          .sort((x,y)=> tsec(y.endedAt||y.startedAt) - tsec(x.endedAt||x.startedAt));

        renderExecs(running);
        renderLane('laneRun', running, 'running', 'Nothing running.');
        renderLane('laneQueue', queued, 'queued', 'Queue empty.');
        renderLane('laneRecent', finished.slice(0,40), null, 'No builds yet.');
        setTxt('hRun', running.length?('· '+running.length):'');
        setTxt('hQueue', queued.length?('· '+queued.length):'');
        setTxt('hRecent', finished.length?('· '+finished.length):'');
        paintTimers();
        if(force) loadJobs();
      }

      function buildCard(b, forceStatus){
        const status = forceStatus || b.status || '';
        const col = SCOL[status] || '#757575';
        const running = status==='running';
        let metaRight;
        if(running){ metaRight = `<span class="lcap" data-started="${esc(b.startedAt||'')}">0s</span>`; }
        else if(status==='queued'){ metaRight = 'waiting'; }
        else { metaRight = fmtDur(b.durationSeconds||0); }
        return `<div class="card ${running?'running':''}" onclick="openDrawer('${encodeURIComponent(b.jobID)}', ${b.number||0})">
          <div class="nm">${running?'<span class=\\"spin\\"></span>':dot(col)}${esc(disp(b.jobID))}</div>
          <div class="meta">
            <span class="badge ${status}">${esc(status||'—')}</span>
            <span>#${b.number||'—'}</span>
            <span style="flex:1"></span>
            <span>${metaRight}</span>
          </div></div>`;
      }

      function renderLane(elId, arr, forceStatus, emptyMsg){
        const el = document.getElementById(elId);
        if(!arr || arr.length===0){ el.innerHTML = `<div class="empty">${emptyMsg}</div>`; return; }
        el.innerHTML = arr.map(b => buildCard(b, forceStatus)).join('');
      }

      // Executor strip: model in-process executors from running builds + an
      // idle slot when nothing is running (swiftci "Build Executor Status").
      function renderExecs(running){
        let html = '';
        for(let i=0;i<running.length;i++){
          const b = running[i];
          html += `<div class="exec busy">
            <div class="top"><span class="spin"></span> #${i+1} &middot; ${esc(disp(b.jobID))}</div>
            <div class="sub"><span>build #${b.number}</span><span class="lcap" data-started="${esc(b.startedAt||'')}">0s</span></div>
            <div class="bar"><i></i></div></div>`;
        }
        const idle = running.length===0 ? 1 : 0;
        for(let i=0;i<idle;i++){
          html += `<div class="exec"><div class="top"><span class="dot" style="background:#555"></span> #${running.length+i+1} &middot; <span class="muted">Idle</span></div>
            <div class="sub">waiting for work</div></div>`;
        }
        document.getElementById('execs').innerHTML = html || '<div class="muted">No executors.</div>';
      }

      // 1s ticker repaints the live elapsed labels (smooth, no refetch).
      function paintTimers(){
        document.querySelectorAll('.lcap[data-started]').forEach(el => {
          el.textContent = fmtDur(elapsed(el.getAttribute('data-started')));
        });
      }
      setInterval(paintTimers, 1000);

      // ---- job rail (trigger) ----
      async function loadJobs(){
        const d = await jget(api('/api/jobs'));
        const g = document.getElementById('jobgrid');
        const ids = (d && d.jobs) || [];
        S.jobs = ids; setTxt('jobCount', '· '+ids.length);
        if(ids.length===0){ g.innerHTML = '<div class="empty">No pipelines yet.</div>'; return; }
        const rec = await jget(api('/api/builds/recent'));
        const recent = (rec && rec.builds) || [];
        const latest = {};
        for(const b of recent){ if(!(b.jobID in latest) || b.number > latest[b.jobID].number) latest[b.jobID] = b; }
        g.innerHTML = ids.slice().sort((a,b)=>disp(a).localeCompare(disp(b))).map(id => {
          const lb = latest[id];
          const col = lb ? (SCOL[lb.status]||'#757575') : '#757575';
          const n = lb ? ('#'+lb.number) : 'never';
          return `<div class="jrow">${dot(col)}
            <span class="nm" title="${esc(disp(id))}">${esc(disp(id))}</span>
            <span class="sub">${n}</span>
            <button class="mini" onclick="event.stopPropagation();runJob('${encodeURIComponent(id)}',this)">&#9654;</button>
            <button class="ghost mini" onclick="openDrawer('${encodeURIComponent(id)}',${lb?lb.number:0})">log</button>
          </div>`;
        }).join('');
      }

      async function runJob(idEnc, btn){
        const id = decodeURIComponent(idEnc);
        if(btn){ btn.disabled=true; btn.textContent='…'; }
        await fetch(api('/api/jobs/' + encodeURIComponent(id) + '/trigger'), { method:'POST' });
        setTimeout(()=>{ tick(true); if(btn){ btn.disabled=false; btn.innerHTML='\\u25B6'; } }, 1200);
      }

      // ---- log drawer ----
      async function openDrawer(idEnc, num){
        const id = decodeURIComponent(idEnc);
        S.selJob = id; S.selBuild = num||null;
        document.getElementById('dName').textContent = disp(id);
        document.getElementById('drawer').classList.add('open');
        document.getElementById('scrim').classList.add('open');
        await loadDrawerBuilds();
      }
      function closeDrawer(){ document.getElementById('drawer').classList.remove('open'); document.getElementById('scrim').classList.remove('open'); S.selJob=null; }
      function triggerSel(){ if(S.selJob) runJob(encodeURIComponent(S.selJob), document.getElementById('dRun')); }

      async function loadDrawerBuilds(){
        if(!S.selJob) return;
        const bl = await jget(api('/api/jobs/' + encodeURIComponent(S.selJob) + '/builds'));
        const nums = ((bl && bl.builds) || []).slice().sort((a,b)=>b-a);
        const el = document.getElementById('dBuilds');
        if(nums.length===0){ el.innerHTML='<span class="muted">No builds yet — press Run.</span>'; document.getElementById('dLog').innerHTML='<div class="empty">No builds yet.</div>'; document.getElementById('dBadge').innerHTML=''; return; }
        const pick = (S.selBuild && nums.indexOf(S.selBuild)>=0) ? S.selBuild : nums[0];
        const show = nums.slice(0, 12);
        const details = {};
        for(const n of show){
          const d = await jget(api('/api/jobs/' + encodeURIComponent(S.selJob) + '/builds/' + n));
          if(d && d.build) details[n] = d.build;
        }
        el.innerHTML = show.map(n => {
          const b = details[n]; const st = b ? b.status : '?';
          return `<span class="bchip ${n===pick?'sel':''}" onclick="showLog(${n})">#${n} · ${esc(st)}</span>`;
        }).join('');
        showLog(pick);
      }
      async function showLog(n){
        S.selBuild = n;
        document.querySelectorAll('#dBuilds .bchip').forEach(c => c.classList.toggle('sel', c.textContent.startsWith('#'+n+' ')));
        const d = await jget(api('/api/jobs/' + encodeURIComponent(S.selJob) + '/builds/' + n));
        const el = document.getElementById('dLog'); const bd = document.getElementById('dBadge');
        if(!d){ el.innerHTML='<div class="empty">Build log unavailable.</div>'; return; }
        const b = d.build || {};
        bd.innerHTML = `<span class="badge ${b.status||''}">${esc(b.status||'?')}</span>`;
        el.textContent = `=== ${disp(S.selJob)} #${n} — ${b.status||'?'} ===\\n` + (d.log || '(no log captured)');
      }

      // ---- header ----
      async function loadHead(){
        const h = await jtext(api('/health'));
        const hp = document.getElementById('health');
        if(h && h.trim()==='ok'){ hp.textContent='healthy'; hp.className='pill ok'; } else { hp.textContent='down'; hp.className='pill down'; }
        const v = await jtext(api('/version'));
        if(v){ setTxt('ver', v.trim()); }
      }

      loadHead(); tick(true);
      setInterval(tick, 2000);
    </script>
    </body>
    </html>
    """
}

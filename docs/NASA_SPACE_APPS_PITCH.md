# NASA Space Apps Challenge Project Pitch: MARTIANBOUND
**Challenge:** Run a Lunar or Martian Outpost (Planetary Data & Human Exploration)  
**Target Audience:** Students Ages 7–12, Educators, and Space Enthusiasts  
**Format:** 2D Top-Down Interactive Mission Trainer (Godot 4)  
**Core Thesis:** *Teaching genuine deep space survival engineering through authentic NASA open data and uncompromising trade-offs.*

---

## 1. How Martianbound Solves the Challenge (10/10 Rubric Alignment)

### A. The Educational Problem: The Translation Gap
Most space-themed content for youth suffers from two extremes:
1. *Posters & Trivia*: Oversimplifies missions without showing why decisions are hard.
2. *Technical Dashboards*: Overwhelms kids with dry spreadsheets that lose their attention.

**Martianbound bridges this gap**: It puts kids directly in the boots of an astronaut commander on Mars for an intensive **1-Sol (24-hour Martian day)** mission. Through tactile pixel-art exploration and instant cause-and-effect decision popups, young learners discover the golden rule of real aerospace engineering: **no choice is free, and every decision carries a trade-off.**

---

## 2. Six Genuine Engineering Trade-Offs Taught Through Play

| Challenge Requirement | In-Game Dilemma & Decision Mechanic | Real NASA Open Data Source |
| :--- | :--- | :--- |
| **1. Power Budgeting** | Solar arrays generate massive power during daylight ($16\text{ kWh}$ step), but zero at night. Overnight, Martian temperatures plunge to $-105^\circ\text{C}$, demanding intense heater load. If batteries hit 0%, the dome blacks out and hypothermia strikes! Overclocking inverters gives $+120\text{ kWh}$ today, but degrades habitat capacitors by $-4\%$. | **NASA InSight TWINS** (`10.17189/1518950`) |
| **2. Radiation Shielding** | Mars has no magnetic shield. Cosmic rays penetrate metal hulls. At the Hab airlock, players can shovel regolith dirt over the dome: *Permanently cuts radiation in half, but costs 15 kWh and exhausts crew stamina!* | **NASA Curiosity MSL-RAD** (`10.17189/1519781`) |
| **3. Communication Delay** | At the Comms Dish, kids discover the **14-minute one-way light-speed delay** between Earth and Mars. Houston cannot remote-control the base; cadets must make autonomous survival decisions on the Martian surface! | **NASA Deep Space Network (DSN)** |
| **4. Subsurface Water Ice (ISRU)** | Accessing the $-38\text{m}$ ice table provides critical water ($+180\text{L}$). But sensors pick up a rhythmic acoustic pulse: *Diverting power ($25\text{ kWh}$) unlocks breakthrough scientific discoveries, but leaves less energy for tonight's heaters!* | **NASA SWIM Project** (`10.17189/1519789`) & **MRO SHARAD** (`10.17189/1520638`) |
| **5. Space Weather Storms** | Coronal Mass Ejections shock fronts strike the surface, spiking radiation to $1.15\text{ mSv/h}$. Players must immediately abort EVA surface walks and seek shelter inside the habitat dome. | **NASA DONKI API** (`api.nasa.gov/DONKI/`) |
| **6. Crew Health & Rest** | Astronauts suffer from fatigue and morale decay. Rest cycles in the habitat consume food and water rations to restore cognitive alertness and vitals, mirroring real spaceflight sleep medicine. | **NASA Open Science Data Repository (OSDR)** |

---

## 3. Designed Specifically for Kids Ages 7–12 & Classrooms

1. **"Cadet Field Guide" Accessible from Main Menu**:
   * Interactive plain-language explanations for kids explaining **Sol**, **mSv radiation**, **atmospheric pressure (kPa)**, and the **14-minute radio lag**.
2. **Visual Emoji Trade-Off Feedback**:
   * Every decision button immediately previews consequences with friendly visual icons:
     `[🛡️ Rad Shield: -40% Exposure | 😓 Fatigue: +14 | 🔋 Power: -15]` vs `[🫁 Safe Reserves | Zero Fatigue]`.
3. **Focused 1-Sol Intensive Experience**:
   * Players can complete a full, gripping expedition loop in 10–15 minutes: from morning touchdown ($08:30$) through midday solar peaks, afternoon dust storms, and tense nighttime survival to morning extraction!
4. **Replayability & Varied Outcomes**:
   * Multiple distinct endings based entirely on player choices: **Mission Success**, **Partial Success**, or **Critical Life-Support Failure**, accompanied by a detailed NASA Mission Control Debrief Dossier.

---

## 4. Academic Traceability for NASA Judges
All open datasets used across Martianbound are documented with official PDS Logical Identifiers and DataCite DOIs in:
* `docs/NASA_DATASET_VERIFICATION.md`
* `assets/data/nasa_mars_datasets.json`

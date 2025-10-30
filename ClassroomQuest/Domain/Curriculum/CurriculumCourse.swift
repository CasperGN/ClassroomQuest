import Foundation
import SwiftUI

struct CurriculumCourse: Identifiable {
    let grade: CurriculumGrade
    let overview: String
    let guidingTheme: String
    let tracks: [CurriculumTrack]

    var id: CurriculumGrade { grade }

    static let catalog: [CurriculumCourse] = [
        .init(
            grade: .preK,
            overview: "Playful discovery with quick-win activities that build confidence in counting, letters, science observation, and kindness.",
            guidingTheme: "Wonder Garden Explorers",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Help the Meadow Sprites gather treasures by counting and matching shapes.",
                    quests: [
                        CurriculumQuest(
                            title: "Apple Basket Count",
                            topic: "Counting 1–10",
                            gameMechanics: ["Drag-and-drop apples into baskets", "Cheerful audio feedback after each drop"],
                            swiftUITechniques: ["Use DragGesture with drop targets to count items", "Trigger withAnimation star bursts and haptics"],
                            reward: "Earn a sticker for the sprite's scrapbook"
                        ),
                        CurriculumQuest(
                            title: "Shape Safari",
                            topic: "Shapes & Patterns",
                            gameMechanics: ["Tap shapes hidden in the scene", "Complete simple repeating patterns"],
                            swiftUITechniques: ["Present shapes in LazyVGrid with tappable cells", "Animate discoveries with matchedGeometryEffect"],
                            reward: "Unlock a new explorer hat for the avatar"
                        ),
                        CurriculumQuest(
                            title: "Tiny Comparison Trail",
                            topic: "Compare Groups",
                            gameMechanics: ["Choose which group has more critters", "Immediate encouragement for each choice"],
                            swiftUITechniques: ["Randomize prompts locally", "Use ProgressView for short streak indicator"],
                            reward: "Collect firefly lights that brighten the map"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Feed the Phonics Monster and paint letters to unlock the alphabet song.",
                    quests: [
                        CurriculumQuest(
                            title: "Letter Painting",
                            topic: "Letter Recognition",
                            gameMechanics: ["Trace uppercase letters with finger", "Voiceover pronunciation on tap"],
                            swiftUITechniques: ["Render letter outlines with Canvas", "Read letters using AVSpeechSynthesizer"],
                            reward: "Add glitter brushes to the painting palette"
                        ),
                        CurriculumQuest(
                            title: "Phonics Picnic",
                            topic: "Beginning Sounds",
                            gameMechanics: ["Drag items that match a sound into a friendly monster's basket"],
                            swiftUITechniques: ["Use .onDrag and .onDrop to classify images", "Play success chimes with AVAudioPlayer"],
                            reward: "Unlock a new picnic blanket pattern"
                        ),
                        CurriculumQuest(
                            title: "Alphabet Parade",
                            topic: "Letter Sequencing",
                            gameMechanics: ["Arrange floating balloons into ABC order", "Short celebration for completion"],
                            swiftUITechniques: ["Animate balloons with spring effects", "Persist completion in Core Data for the parent report"],
                            reward: "Earn parade badges displayed in the sticker book"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Visit the Wonder Garden and identify senses, animals, and weather.",
                    quests: [
                        CurriculumQuest(
                            title: "Sense Detective",
                            topic: "Five Senses",
                            gameMechanics: ["Tap objects to match sense icons", "Reveal fun sound/voice clips"],
                            swiftUITechniques: ["Display scenes with layered ZStack", "Trigger AVSpeechSynthesizer narration per discovery"],
                            reward: "Grow a sensory flower in the kid's garden"
                        ),
                        CurriculumQuest(
                            title: "Animal Sound Hunt",
                            topic: "Animals & Habitats",
                            gameMechanics: ["Guess animals from their sounds", "Simple quiz after free exploration"],
                            swiftUITechniques: ["Bundle audio clips for offline playback", "Show randomized prompts using shuffled arrays"],
                            reward: "Collect habitat cards for the field journal"
                        ),
                        CurriculumQuest(
                            title: "Weather Wheel",
                            topic: "Weather Basics",
                            gameMechanics: ["Spin a weather wheel and dress a character appropriately"],
                            swiftUITechniques: ["Animate rotation with rotationEffect", "Store outfit choices in Core Data as artifacts"],
                            reward: "Unlock a rainbow trail animation on the map"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Guide gentle creatures to make kind choices around the Wonder Garden chapel.",
                    quests: [
                        CurriculumQuest(
                            title: "Sharing Seeds",
                            topic: "Sharing & Kindness",
                            gameMechanics: ["Choose kind actions in short vignettes", "Receive immediate hugs and hearts"],
                            swiftUITechniques: ["Present branching options with Buttons inside a TabView story", "Animate heart icons using withAnimation"],
                            reward: "Earn kindness gems that unlock lullaby music"
                        ),
                        CurriculumQuest(
                            title: "Color the Symbols",
                            topic: "Faith & Community Symbols",
                            gameMechanics: ["Finger-paint symbols like crosses or doves"],
                            swiftUITechniques: ["Implement DrawingCanvas for finger painting", "Persist artwork to Core Data for parent gallery"],
                            reward: "Add the colored symbol to the chapel stained glass"
                        ),
                        CurriculumQuest(
                            title: "Feelings Garden",
                            topic: "Emotions Vocabulary",
                            gameMechanics: ["Match emotions to friendly creatures", "Breathing mini-break after each set"],
                            swiftUITechniques: ["Use Lottie or Particle effects to calm the scene", "Schedule breathing timer with TimelineView"],
                            reward: "Unlock a new calming background for bedtime mode"
                        )
                    ]
                )
            ]
        ),
        .init(
            grade: .kindergarten,
            overview: "Story-driven quests introduce structured practice with manipulatives, sight words, and nature missions.",
            guidingTheme: "Neighborhood Quest Buddies",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Join Builder Bot to stack number blocks and solve early addition puzzles.",
                    quests: [
                        CurriculumQuest(
                            title: "Number Block Adventure",
                            topic: "Counting to 20",
                            gameMechanics: ["Stack draggable blocks to reach target numbers", "Celebrate streaks with glow effects"],
                            swiftUITechniques: ["Create draggable manipulatives with ForEach", "Animate streak badge via ProgressView"],
                            reward: "Unlock blueprint pieces for Builder Bot's workshop"
                        ),
                        CurriculumQuest(
                            title: "Snack Shop Sums",
                            topic: "Intro Addition & Subtraction",
                            gameMechanics: ["Serve snacks by solving addition/subtraction stories"],
                            swiftUITechniques: ["Use card-style prompts in LazyVStack", "Persist mastery per operation in Core Data"],
                            reward: "Earn recipe cards for the snack stand"
                        ),
                        CurriculumQuest(
                            title: "Measure Trail",
                            topic: "Non-standard Measurement",
                            gameMechanics: ["Drag shoes or blocks to measure playground objects"],
                            swiftUITechniques: ["Detect placements with GeometryReader", "Snap pieces into place using withAnimation"],
                            reward: "Collect explorer badges on the quest map"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Form sight words, rhyme with forest critters, and build tiny stories.",
                    quests: [
                        CurriculumQuest(
                            title: "Sight Word Garden",
                            topic: "Sight Words",
                            gameMechanics: ["Tap glowing word flowers to hear and read", "Match word cards to pictures"],
                            swiftUITechniques: ["Highlight text with background modifiers", "Use AVSpeechSynthesizer to speak words"],
                            reward: "Grow animated butterflies around the reading nook"
                        ),
                        CurriculumQuest(
                            title: "Rhyme River",
                            topic: "Rhyming",
                            gameMechanics: ["Row a boat by pairing rhyming words", "Timed gentle races"],
                            swiftUITechniques: ["Drive timers with TimelineView", "Animate boat using offset transitions"],
                            reward: "Unlock new oars and boat colors"
                        ),
                        CurriculumQuest(
                            title: "Story Stones",
                            topic: "Simple Sentences",
                            gameMechanics: ["Arrange story stones (subject, verb, object) to tell mini tales"],
                            swiftUITechniques: ["Support drag reordering with DropDelegate", "Store stories in Core Data for replay"],
                            reward: "Collect storybook covers for the shelf"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Collect weather data and care for classroom plants.",
                    quests: [
                        CurriculumQuest(
                            title: "Weather Station",
                            topic: "Weather & Seasons",
                            gameMechanics: ["Record weather observations", "Dress avatars for conditions"],
                            swiftUITechniques: ["Use Toggle & Picker controls for logs", "Animate backgrounds per weather state"],
                            reward: "Unlock a forecast widget on the home screen"
                        ),
                        CurriculumQuest(
                            title: "Habitat Builder",
                            topic: "Animal Habitats",
                            gameMechanics: ["Place animals into matching habitats", "Earn collection cards"],
                            swiftUITechniques: ["Use LazyVGrid palettes with DropDelegate", "Animate habitat completion with scale effects"],
                            reward: "Add habitat diorama pieces to the classroom"
                        ),
                        CurriculumQuest(
                            title: "Plant Patrol",
                            topic: "Plant Needs",
                            gameMechanics: ["Adjust sunlight and water sliders", "Watch plant growth animation"],
                            swiftUITechniques: ["Bind sliders to stateful growth model", "Animate growth with TimelineView"],
                            reward: "Unlock new seeds for the science corner"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Meet community helpers and practice empathy through role-play.",
                    quests: [
                        CurriculumQuest(
                            title: "Helper HQ",
                            topic: "Community Helpers",
                            gameMechanics: ["Choose helper tools for different jobs", "Branching scenarios"],
                            swiftUITechniques: ["Use NavigationStack for narrative flow", "Record decisions to Core Data for parent recap"],
                            reward: "Unlock helper badges and costume pieces"
                        ),
                        CurriculumQuest(
                            title: "Family Tree Time",
                            topic: "Family Roles",
                            gameMechanics: ["Assemble animated family trees", "Record thank-you notes"],
                            swiftUITechniques: ["Implement DragGesture connectors", "Allow parent-recorded encouragement using AVAudioRecorder"],
                            reward: "Add portraits to the in-app clubhouse"
                        ),
                        CurriculumQuest(
                            title: "Neighborhood Map",
                            topic: "Basic Geography",
                            gameMechanics: ["Puzzle together map tiles to rebuild the neighborhood"],
                            swiftUITechniques: ["Snap tiles with matchedGeometryEffect", "Use MapKit snapshots for context"],
                            reward: "Reveal hidden playground locations on the main map"
                        )
                    ]
                )
            ]
        ),
        .init(
            grade: .grade1,
            overview: "Chapter-based missions combine math boss battles, early comprehension, and civic adventures.",
            guidingTheme: "Clockwork Town Guardians",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Repair Clockwork Town by mastering mixed operations and telling time.",
                    quests: [
                        CurriculumQuest(
                            title: "Gear Up Addition",
                            topic: "Addition/Subtraction to 20",
                            gameMechanics: ["Complete timed gears by solving equations", "Boss fight mixes operation types"],
                            swiftUITechniques: ["Drive timers with TimelineView", "Store boss levels as GameLevel entities"],
                            reward: "Unlock gear motifs for the avatar"
                        ),
                        CurriculumQuest(
                            title: "Place Value Workshop",
                            topic: "Tens and Ones",
                            gameMechanics: ["Drag rods and units to build numbers", "Earn upgrade parts"],
                            swiftUITechniques: ["Represent rods with GeometryReader-based stacks", "Use haptic feedback on correct placements"],
                            reward: "Add new workshop tools to the HQ"
                        ),
                        CurriculumQuest(
                            title: "Time Keeper Trials",
                            topic: "Time to Hour & Half Hour",
                            gameMechanics: ["Set analog clocks for townsfolk tasks", "Unlock story cutscenes"],
                            swiftUITechniques: ["Wheel pickers for hour/minute hands", "SpriteKit scene for cinematic reveals"],
                            reward: "Activate new areas in Clockwork Town"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Guide storybook heroes through comprehension checkpoints and grammar puzzles.",
                    quests: [
                        CurriculumQuest(
                            title: "Chapter Checkpoint",
                            topic: "Reading Comprehension",
                            gameMechanics: ["Read short passages then answer branching questions"],
                            swiftUITechniques: ["Highlight text as audio plays", "Use List of MultipleChoiceQuestion views"],
                            reward: "Collect illustration cards for the library"
                        ),
                        CurriculumQuest(
                            title: "Grammar Garden",
                            topic: "Nouns & Verbs",
                            gameMechanics: ["Sort words into glowing plots", "Unlock secret sentences"],
                            swiftUITechniques: ["Use DropDelegate for category sorting", "Animate successful matches with scale effects"],
                            reward: "Grow grammar flowers that decorate the home hub"
                        ),
                        CurriculumQuest(
                            title: "Story Forge",
                            topic: "Sentence Building",
                            gameMechanics: ["Craft sentences from word tiles", "Add to hero's journal"],
                            swiftUITechniques: ["Implement tile drag grid", "Persist journal entries to Core Data"],
                            reward: "Unlock hero emotes for story playback"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Discover life cycles and states of matter in interactive labs.",
                    quests: [
                        CurriculumQuest(
                            title: "Lifecycle Lab",
                            topic: "Animal & Plant Cycles",
                            gameMechanics: ["Arrange stages on a timeline", "Unlock animations"],
                            swiftUITechniques: ["TimelineView to animate progress", "Trigger animations with matchedGeometryEffect"],
                            reward: "Collect holographic life cycle cards"
                        ),
                        CurriculumQuest(
                            title: "Matter Mixer",
                            topic: "States of Matter",
                            gameMechanics: ["Heat or cool water particles to observe changes"],
                            swiftUITechniques: ["SpriteKit particle scene for states", "Control temperature with Slider bound to simulation"],
                            reward: "Unlock lab equipment skins"
                        ),
                        CurriculumQuest(
                            title: "Super Sense Review",
                            topic: "Human Senses",
                            gameMechanics: ["Match senses to activities in quick rounds"],
                            swiftUITechniques: ["Use cards with flipping animations", "Track accuracy streaks with Combine publishers"],
                            reward: "Earn lab assistant companion"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Help citizens rebuild their community park through civic choices.",
                    quests: [
                        CurriculumQuest(
                            title: "Town Treasure Hunt",
                            topic: "Local History",
                            gameMechanics: ["Solve clues around a map", "Collect artifacts"],
                            swiftUITechniques: ["Overlay MapKit snapshot with tappable markers", "Persist found artifacts in Core Data"],
                            reward: "Display artifacts in the community museum"
                        ),
                        CurriculumQuest(
                            title: "Civic Helpers",
                            topic: "Basic Civics",
                            gameMechanics: ["Allocate resources to community needs", "Cause-and-effect feedback"],
                            swiftUITechniques: ["Use Sliders and Charts to show resource impact", "Record decisions for parent dashboard insights"],
                            reward: "Earn town improvement badges"
                        ),
                        CurriculumQuest(
                            title: "Kind Choice Corners",
                            topic: "Social Problem Solving",
                            gameMechanics: ["Choose responses in peer scenarios", "Reflect with journaling prompts"],
                            swiftUITechniques: ["Present choices as Buttons with recorded outcomes", "Offer optional audio journal via AVAudioRecorder"],
                            reward: "Unlock park decorations chosen by the learner"
                        )
                    ]
                )
            ]
        ),
        .init(
            grade: .grade2,
            overview: "Cooperative quests, weather labs, and storytelling decks deepen critical thinking and creativity.",
            guidingTheme: "Skyship Expedition",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Upgrade the expedition airship using double-digit operations and budding multiplication.",
                    quests: [
                        CurriculumQuest(
                            title: "Sky Dock Sums",
                            topic: "Add/Subtract to 100",
                            gameMechanics: ["Repair ship parts by solving column problems", "Combo meter for consecutive wins"],
                            swiftUITechniques: ["Display column alignment with custom Grid", "Animate combo meter using Combine timers"],
                            reward: "Unlock new ship sails and decals"
                        ),
                        CurriculumQuest(
                            title: "Cargo Crew",
                            topic: "Intro Multiplication",
                            gameMechanics: ["Load crates in equal groups", "AI companion offers hints"],
                            swiftUITechniques: ["Represent arrays with LazyVGrid", "Surface hints triggered by low mastery"],
                            reward: "Adopt a helpful robo-parrot companion"
                        ),
                        CurriculumQuest(
                            title: "Time Trader",
                            topic: "Time to 5 Minutes & Money",
                            gameMechanics: ["Run a trading post with clocks and coin change challenges"],
                            swiftUITechniques: ["Use TimelineView for countdown challenges", "Drag coins with matchedGeometryEffect transitions"],
                            reward: "Unlock merchant costumes and stall upgrades"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Collect story sparks to compose multi-sentence adventures.",
                    quests: [
                        CurriculumQuest(
                            title: "Story Forge Deck",
                            topic: "Paragraph Sequencing",
                            gameMechanics: ["Arrange story cards into beginning, middle, end"],
                            swiftUITechniques: ["Stack cards using ZStack with drag gestures", "Persist favorite sequences for reuse"],
                            reward: "Unlock new illustration packs"
                        ),
                        CurriculumQuest(
                            title: "Wordsmith Workshop",
                            topic: "Adjectives & Descriptions",
                            gameMechanics: ["Spin adjective wheels to enhance sentences", "Score style points"],
                            swiftUITechniques: ["Use Picker with wheel style", "Scoreboard animated via withAnimation"],
                            reward: "Earn design patterns for the writing journal"
                        ),
                        CurriculumQuest(
                            title: "Creative Captains",
                            topic: "Writing Basics",
                            gameMechanics: ["Respond to prompts with text or voice", "NPC feedback badges"],
                            swiftUITechniques: ["Use TextEditor with autosave", "Offer optional SpeechRecognizer dictation offline"],
                            reward: "Unlock cabin décor themed to stories"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Chart weather patterns and engineer balanced habitats on distant islands.",
                    quests: [
                        CurriculumQuest(
                            title: "Weather Lab",
                            topic: "Weather Patterns",
                            gameMechanics: ["Record temperatures and precipitation over multiple days"],
                            swiftUITechniques: ["Plot data using Swift Charts", "Schedule review prompts with UNUserNotificationCenter"],
                            reward: "Unlock forecast instruments for the airship"
                        ),
                        CurriculumQuest(
                            title: "Habitat Sandbox",
                            topic: "Ecosystem Balance",
                            gameMechanics: ["Place flora and fauna with resource limits", "Maintain health meter"],
                            swiftUITechniques: ["Use DropDelegate for placement", "Animate health meter with gradient ProgressView"],
                            reward: "Adopt new animal buddies for the ship"
                        ),
                        CurriculumQuest(
                            title: "Experiment Log",
                            topic: "Scientific Method Basics",
                            gameMechanics: ["Run simple experiments with variable toggles", "Record observations"],
                            swiftUITechniques: ["Bind toggles to state machine", "Store notes and photos in Core Data attachments"],
                            reward: "Earn scientist patches on the expedition jacket"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Celebrate cultures discovered on each island and practice thoughtful choices.",
                    quests: [
                        CurriculumQuest(
                            title: "Culture Exchange",
                            topic: "World Cultures",
                            gameMechanics: ["Collect artifacts by answering cultural trivia", "Unlock festival scenes"],
                            swiftUITechniques: ["Display collections with LazyHGrid", "Animate festival reveal with transitions"],
                            reward: "Add cultural decor to the skyship commons"
                        ),
                        CurriculumQuest(
                            title: "Map Makers",
                            topic: "Mapping Skills",
                            gameMechanics: ["Plot routes between islands", "Estimate distances"],
                            swiftUITechniques: ["Overlay MapKit polylines", "Compute distances locally with MKMapPoint"],
                            reward: "Unlock navigation compass skins"
                        ),
                        CurriculumQuest(
                            title: "Decision Deck",
                            topic: "Community Choices",
                            gameMechanics: ["Play cards to resolve dilemmas", "See immediate narrative consequences"],
                            swiftUITechniques: ["Model branching outcomes with state machine", "Store decision history for parent insights"],
                            reward: "Earn leadership badges for the captain's log"
                        )
                    ]
                )
            ]
        ),
        .init(
            grade: .grade3,
            overview: "Challenge mode unlocks dungeon crawls, fraction crafting, and civic decision trees with optional leaderboards.",
            guidingTheme: "Mystic Forest Guild",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Delve into the Mystic Forest to defeat math guardians using multiplication, division, and fractions.",
                    quests: [
                        CurriculumQuest(
                            title: "Multiplication Gauntlet",
                            topic: "Multiplication Facts",
                            gameMechanics: ["Battle guardians with quick-fire facts", "Combo streak unlocks power moves"],
                            swiftUITechniques: ["Embed SpriteKit battle scene", "Sync combos via Combine publisher"],
                            reward: "Unlock enchanted weapons for avatars"
                        ),
                        CurriculumQuest(
                            title: "Fraction Forge",
                            topic: "Fraction Modeling",
                            gameMechanics: ["Cut shapes to craft fractions", "Assemble fraction recipes"],
                            swiftUITechniques: ["Use Canvas for slicing interactions", "Store creations as images for review"],
                            reward: "Collect luminous fraction crystals"
                        ),
                        CurriculumQuest(
                            title: "Area & Perimeter Patrol",
                            topic: "Geometry Basics",
                            gameMechanics: ["Scout forest clearings by calculating area/perimeter"],
                            swiftUITechniques: ["Grid overlays with GeometryReader", "Hint system tied to mastery engine"],
                            reward: "Expand guild treehouse rooms"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Investigate mysteries by synthesizing passages, vocabulary, and figurative language.",
                    quests: [
                        CurriculumQuest(
                            title: "Mystery Files",
                            topic: "Reading Comprehension",
                            gameMechanics: ["Collect clues after reading case files", "Inference challenges"],
                            swiftUITechniques: ["Use NavigationSplitView for case board", "Tag evidence with swipe actions"],
                            reward: "Unlock detective gadgets for avatars"
                        ),
                        CurriculumQuest(
                            title: "Word Wizard Arena",
                            topic: "Vocabulary & Prefixes",
                            gameMechanics: ["Cast spells by matching roots and prefixes"],
                            swiftUITechniques: ["Animate spells with Particle effects", "Track mastery tiers in Core Data"],
                            reward: "Earn spell animations for the quest map"
                        ),
                        CurriculumQuest(
                            title: "Poetry Grove",
                            topic: "Figurative Language",
                            gameMechanics: ["Identify similes/metaphors", "Compose short poem cards"],
                            swiftUITechniques: ["Provide prompt templates with TextEditor", "Render poems on collectible cards"],
                            reward: "Grow glowing poetry vines in the grove"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Study energy, life cycles, and Earth changes through interactive quests.",
                    quests: [
                        CurriculumQuest(
                            title: "Ecosystem Watch",
                            topic: "Ecosystems",
                            gameMechanics: ["Balance predator/prey counts", "Weekly check-ins"],
                            swiftUITechniques: ["Persist data with Core Data schedules", "Use Charts to show population trends"],
                            reward: "Unlock new biomes within the forest"
                        ),
                        CurriculumQuest(
                            title: "Energy Lab",
                            topic: "Energy Transfer",
                            gameMechanics: ["Simulate light/heat experiments", "Visualize transformations"],
                            swiftUITechniques: ["Use TimelineView to animate energy flow", "Add overlays explaining results"],
                            reward: "Earn energy totems powering the guild hall"
                        ),
                        CurriculumQuest(
                            title: "Rock Cycle Run",
                            topic: "Rock Cycle",
                            gameMechanics: ["Guide rocks through melting, cooling, weathering"],
                            swiftUITechniques: ["Animate cycle timeline with Stepper", "Store milestone screenshots for parent review"],
                            reward: "Collect rock badges for the geology wing"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Lead the guild council through historical dilemmas and map expeditions.",
                    quests: [
                        CurriculumQuest(
                            title: "Branches of Government",
                            topic: "Civics",
                            gameMechanics: ["Build government tree and assign roles"],
                            swiftUITechniques: ["Render tree structure with custom view", "Animate node highlights on selection"],
                            reward: "Unlock council chamber upgrades"
                        ),
                        CurriculumQuest(
                            title: "History Chronicles",
                            topic: "National History",
                            gameMechanics: ["Interactive timelines with key events", "Choice-driven reflections"],
                            swiftUITechniques: ["Horizontal ScrollView timeline", "Store reflection responses in Core Data"],
                            reward: "Add pages to the guild chronicle book"
                        ),
                        CurriculumQuest(
                            title: "Explorer Maps",
                            topic: "Advanced Map Skills",
                            gameMechanics: ["Plan expeditions using scale and coordinates"],
                            swiftUITechniques: ["Overlay coordinates on MapKit", "Offer measurement tools with gestures"],
                            reward: "Reveal hidden forest shrines"
                        )
                    ]
                )
            ]
        ),
        .init(
            grade: .grade4,
            overview: "Learners tackle multi-step operations, literary analysis, and government simulations with increased autonomy.",
            guidingTheme: "Innovation Harbor",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Restore Innovation Harbor's power grid using long operations and advanced fractions.",
                    quests: [
                        CurriculumQuest(
                            title: "Power Grid Puzzles",
                            topic: "Multi-digit Operations",
                            gameMechanics: ["Route energy by solving long addition/subtraction"],
                            swiftUITechniques: ["Support long-form input with column aligned text fields", "Provide contextual hints after errors"],
                            reward: "Unlock harbor district upgrades"
                        ),
                        CurriculumQuest(
                            title: "Fraction Marketplace",
                            topic: "Equivalent & Comparing Fractions",
                            gameMechanics: ["Trade resources by matching equivalent fractions", "Competitive challenges"],
                            swiftUITechniques: ["Use Charts to visualize fraction bars", "Enable optional GameKit leaderboard"],
                            reward: "Gain merchant alliance perks"
                        ),
                        CurriculumQuest(
                            title: "Engineer Bay",
                            topic: "Multi-digit Multiplication & Division",
                            gameMechanics: ["Manufacture parts using multiplication/division chains"],
                            swiftUITechniques: ["Chain questions via state machine", "Persist multi-step progress for resume"],
                            reward: "Unlock engineering drone companions"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Run an investigative newsroom analyzing novels and grammar intricacies.",
                    quests: [
                        CurriculumQuest(
                            title: "Novel Newsroom",
                            topic: "Literary Analysis",
                            gameMechanics: ["Collect textual evidence for story reports"],
                            swiftUITechniques: ["Use split view for text + notes", "Tag evidence chips with swipe actions"],
                            reward: "Unlock newsroom equipment skins"
                        ),
                        CurriculumQuest(
                            title: "Grammar Workshop",
                            topic: "Advanced Grammar",
                            gameMechanics: ["Repair sentences using drag-and-drop grammar tiles"],
                            swiftUITechniques: ["Reusable drag tile components", "Provide inline feedback with attributed strings"],
                            reward: "Earn editor badges"
                        ),
                        CurriculumQuest(
                            title: "Media Lab",
                            topic: "Media Literacy",
                            gameMechanics: ["Critique multimedia messages", "Tag persuasive techniques"],
                            swiftUITechniques: ["Local AVPlayer for video", "Overlay annotation tools with shapes"],
                            reward: "Unlock media studio backgrounds"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Operate harbor labs exploring energy, Earth systems, and engineering.",
                    quests: [
                        CurriculumQuest(
                            title: "Energy Transfer Lab",
                            topic: "Energy & Waves",
                            gameMechanics: ["Tune wave generators to match target patterns"],
                            swiftUITechniques: ["Plot waveforms with Canvas", "Provide slider-based control and live feedback"],
                            reward: "Upgrade lab reactors"
                        ),
                        CurriculumQuest(
                            title: "Earth Systems Mission",
                            topic: "Earth Processes",
                            gameMechanics: ["Simulate erosion and deposition", "Compare outcomes"],
                            swiftUITechniques: ["SceneKit terrain manipulation", "Record before/after snapshots"],
                            reward: "Unlock exploration submarines"
                        ),
                        CurriculumQuest(
                            title: "Engineering Challenges",
                            topic: "Simple Machines",
                            gameMechanics: ["Build simple machines to solve tasks"],
                            swiftUITechniques: ["Use physics-based SpriteKit scenes", "Track efficiency metrics in Core Data"],
                            reward: "Earn innovation trophies"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Engage in government simulations and ethical debates for the harbor council.",
                    quests: [
                        CurriculumQuest(
                            title: "Harbor Council",
                            topic: "Government Branches",
                            gameMechanics: ["Assign branch powers in scenario cards"],
                            swiftUITechniques: ["Represent branches with interactive diagrams", "Log outcomes for parent dashboard"],
                            reward: "Unlock council chamber seating and insignias"
                        ),
                        CurriculumQuest(
                            title: "Economy Simulator",
                            topic: "Economics Basics",
                            gameMechanics: ["Manage supply/demand to keep harbor thriving"],
                            swiftUITechniques: ["Charts to show supply curves", "Inventory management UI with List"],
                            reward: "Gain trade route boosts"
                        ),
                        CurriculumQuest(
                            title: "Ethics Forum",
                            topic: "Ethical Decision Making",
                            gameMechanics: ["Debate choices with NPC peers", "Reflect on consequences"],
                            swiftUITechniques: ["Dialog trees with state machine", "Store reflections as markdown notes"],
                            reward: "Earn peacemaker laurels"
                        )
                    ]
                )
            ]
        ),
        .init(
            grade: .grade5,
            overview: "Expedition quests combine rich data analysis, advanced writing, and immersive science missions.",
            guidingTheme: "Frontier Research Alliance",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Lead research expeditions solving fraction operations, decimals, and volume puzzles.",
                    quests: [
                        CurriculumQuest(
                            title: "Fraction Expedition",
                            topic: "Fraction Operations",
                            gameMechanics: ["Navigate routes by solving fraction puzzles"],
                            swiftUITechniques: ["Fraction bars with GeometryReader", "Chain multi-step prompts with narrative"],
                            reward: "Unlock expedition gear skins"
                        ),
                        CurriculumQuest(
                            title: "Decimal Data Lab",
                            topic: "Decimals & Graphing",
                            gameMechanics: ["Collect samples and plot decimal data"],
                            swiftUITechniques: ["Swift Charts scatter/line plots", "Export summary to PDF"],
                            reward: "Add scientific instruments to the base"
                        ),
                        CurriculumQuest(
                            title: "Volume Vault",
                            topic: "Volume & 3D Shapes",
                            gameMechanics: ["Construct 3D shapes to store artifacts"],
                            swiftUITechniques: ["SceneKit manipulation gestures", "Persist designs for parent review"],
                            reward: "Unlock holographic display cases"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Investigate historical mysteries with research skills and persuasive writing.",
                    quests: [
                        CurriculumQuest(
                            title: "Investigation Notes",
                            topic: "Research Skills",
                            gameMechanics: ["Gather sources, tag credibility"],
                            swiftUITechniques: ["NavigationSplitView for sources", "Tagging with swipe actions"],
                            reward: "Unlock research assistant bots"
                        ),
                        CurriculumQuest(
                            title: "Figurative Language Studio",
                            topic: "Figurative Language",
                            gameMechanics: ["Identify and craft figurative phrases"],
                            swiftUITechniques: ["Interactive checklist for figurative types", "Audio narration for dramatic readings"],
                            reward: "Earn spotlight animations for presentations"
                        ),
                        CurriculumQuest(
                            title: "Argument Builder",
                            topic: "Argumentative Writing",
                            gameMechanics: ["Assemble claim, evidence, reasoning cards", "Peer-style NPC feedback"],
                            swiftUITechniques: ["Card deck arrangement with DragGesture", "Rubric scoring view for feedback"],
                            reward: "Unlock debate stage cosmetics"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Conduct mission control simulations and long-term ecosystem monitoring.",
                    quests: [
                        CurriculumQuest(
                            title: "Mission Control",
                            topic: "Space & Earth Systems",
                            gameMechanics: ["Adjust mission variables to maintain spacecraft health"],
                            swiftUITechniques: ["Dashboard with gauges using SwiftUI", "Timers and alerts via Combine"],
                            reward: "Unlock mission patches and call signs"
                        ),
                        CurriculumQuest(
                            title: "Mixture Lab",
                            topic: "Mixtures & Solutions",
                            gameMechanics: ["Mix virtual chemicals to achieve target outcomes"],
                            swiftUITechniques: ["SpriteKit particle mixing", "Log data to Core Data lab notebook"],
                            reward: "Earn lab safety gear items"
                        ),
                        CurriculumQuest(
                            title: "Ecosystem Watchtower",
                            topic: "Ecosystem Monitoring",
                            gameMechanics: ["Schedule check-ins and respond to ecosystem events"],
                            swiftUITechniques: ["Local notifications for follow-ups", "Charts for long-term trend visualization"],
                            reward: "Unlock wildlife cams in the base"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Lead debates and strategy missions to explore history and civic responsibility.",
                    quests: [
                        CurriculumQuest(
                            title: "Historical Timeline Forge",
                            topic: "US History",
                            gameMechanics: ["Assemble interactive timelines", "Make perspective-taking notes"],
                            swiftUITechniques: ["Scrollable timeline with LazyHStack", "Annotate events with context menus"],
                            reward: "Unlock museum exhibits in the alliance HQ"
                        ),
                        CurriculumQuest(
                            title: "Debate Arena",
                            topic: "Debate & Civics",
                            gameMechanics: ["Turn-based debates with persuasion meter"],
                            swiftUITechniques: ["State-driven dialog view", "Optional GameKit turn handling"],
                            reward: "Earn leadership titles and banners"
                        ),
                        CurriculumQuest(
                            title: "Strategy Maps",
                            topic: "Geography & Economics",
                            gameMechanics: ["Manage trade routes and resources on strategic maps"],
                            swiftUITechniques: ["MapKit overlays with resource icons", "Charts summarizing supply demand"],
                            reward: "Unlock alliance trade routes"
                        )
                    ]
                )
            ]
        ),
        .init(
            grade: .grade6,
            overview: "Quest chains introduce ratios, advanced writing, and scientific inquiry with branching diplomacy missions.",
            guidingTheme: "Global Guardians",
            tracks: [
                CurriculumTrack(
                    subject: .math,
                    storyline: "Balance city regions using ratios, integers, and coordinate challenges.",
                    quests: [
                        CurriculumQuest(
                            title: "Ratio Rescue",
                            topic: "Ratios & Rates",
                            gameMechanics: ["Adjust recipe ratios to aid regions", "Challenge mode with limited supplies"],
                            swiftUITechniques: ["Use sliders and steppers bound to ratio models", "Provide hint tiers triggered by errors"],
                            reward: "Unlock ration packs that boost future quests"
                        ),
                        CurriculumQuest(
                            title: "Integer Ice Caves",
                            topic: "Integers",
                            gameMechanics: ["Navigate caves by solving integer puzzles"],
                            swiftUITechniques: ["Coordinate plane rendered via Canvas", "Animate character moves per correct answer"],
                            reward: "Unlock guardian pets with elemental powers"
                        ),
                        CurriculumQuest(
                            title: "Coordinate Command",
                            topic: "Coordinate Planes & Algebraic Thinking",
                            gameMechanics: ["Battle battleships on coordinate grids", "Solve algebra gates to advance"],
                            swiftUITechniques: ["Plot interactive grids with Canvas", "Equation builder validating input locally"],
                            reward: "Gain access to advanced quest chains"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .language,
                    storyline: "Investigate global mysteries through literary analysis and persuasive writing.",
                    quests: [
                        CurriculumQuest(
                            title: "Evidence Lab",
                            topic: "Literary Analysis",
                            gameMechanics: ["Tag textual evidence to support claims"],
                            swiftUITechniques: ["Split view for text and annotation", "Evidence tagging with swipe gestures"],
                            reward: "Unlock analysis lenses that highlight themes"
                        ),
                        CurriculumQuest(
                            title: "Debate League",
                            topic: "Argumentative Writing & Speaking",
                            gameMechanics: ["Prepare cases, then debate AI or siblings"],
                            swiftUITechniques: ["Dialog turn engine using Combine", "Optional GameKit turn sync"],
                            reward: "Earn debate trophies and hall of fame placement"
                        ),
                        CurriculumQuest(
                            title: "Media Investigation",
                            topic: "Media Literacy",
                            gameMechanics: ["Critique multimedia sources and identify bias"],
                            swiftUITechniques: ["Local AVPlayer with annotation overlays", "Store media critiques with markdown support"],
                            reward: "Unlock newsroom studio upgrades"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .science,
                    storyline: "Lead global labs exploring cells, energy, and climate feedback systems.",
                    quests: [
                        CurriculumQuest(
                            title: "Cell City",
                            topic: "Cells & Systems",
                            gameMechanics: ["Build cell models by placing organelles", "Quiz-based defense mini-game"],
                            swiftUITechniques: ["Use DragGesture to place organelles", "Animate defenses via SpriteKit"],
                            reward: "Unlock microscopy filters for lab view"
                        ),
                        CurriculumQuest(
                            title: "Energy Network",
                            topic: "Energy Transfer",
                            gameMechanics: ["Optimize energy grids with variable inputs"],
                            swiftUITechniques: ["Sliders to adjust inputs", "Charts/graphs showing efficiency"],
                            reward: "Gain energy cores powering new missions"
                        ),
                        CurriculumQuest(
                            title: "Climate Quest",
                            topic: "Earth Systems & Scientific Method",
                            gameMechanics: ["Run multi-variable experiments to stabilize climate", "Log hypotheses/results"],
                            swiftUITechniques: ["Store experiments in Core Data", "Use Charts for trend analysis", "Schedule reminders for follow-up"],
                            reward: "Unlock global diplomacy missions"
                        )
                    ]
                ),
                CurriculumTrack(
                    subject: .values,
                    storyline: "Negotiate peace, manage trade, and explore ethics across continents.",
                    quests: [
                        CurriculumQuest(
                            title: "Diplomacy Nexus",
                            topic: "Global Citizenship",
                            gameMechanics: ["Navigate branching diplomacy stories"],
                            swiftUITechniques: ["Graph-based state machine for decisions", "Persist outcomes to influence future quests"],
                            reward: "Unlock alliance flags and anthem"
                        ),
                        CurriculumQuest(
                            title: "Trade Winds",
                            topic: "Economics & Trade",
                            gameMechanics: ["Balance supply/demand across regions", "Respond to random events"],
                            swiftUITechniques: ["Charts for market trends", "Inventory UI with virtualization"],
                            reward: "Gain trade bonuses for the guardian council"
                        ),
                        CurriculumQuest(
                            title: "Ethics Council",
                            topic: "Ethical Decision Challenges",
                            gameMechanics: ["Debate solutions with NPC council", "Reflect via journaling"],
                            swiftUITechniques: ["Dialog engine using state machine", "Markdown-friendly journal saved to Core Data"],
                            reward: "Earn world harmony emblems"
                        )
                    ]
                )
            ]
        )
    ]
}

struct CurriculumTrack: Identifiable {
    let subject: CurriculumSubject
    let storyline: String
    let quests: [CurriculumQuest]

    var id: CurriculumSubject { subject }
}

struct CurriculumQuest: Identifiable {
    let id = UUID()
    let title: String
    let topic: String
    let gameMechanics: [String]
    let swiftUITechniques: [String]
    let reward: String
}

enum CurriculumGrade: String, CaseIterable, Identifiable {
    case preK
    case kindergarten
    case grade1
    case grade2
    case grade3
    case grade4
    case grade5
    case grade6

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .preK: return "Pre-K"
        case .kindergarten: return "Kindergarten"
        case .grade1: return "Grade 1"
        case .grade2: return "Grade 2"
        case .grade3: return "Grade 3"
        case .grade4: return "Grade 4"
        case .grade5: return "Grade 5"
        case .grade6: return "Grade 6"
        }
    }
}

enum CurriculumSubject: CaseIterable, Identifiable {
    case math
    case language
    case science
    case values

    var id: Self { self }

    var displayName: String {
        switch self {
        case .math: return "Math"
        case .language: return "Language"
        case .science: return "Science"
        case .values: return "Social & Values"
        }
    }

    var iconSystemName: String {
        switch self {
        case .math: return "function"
        case .language: return "book.fill"
        case .science: return "leaf.fill"
        case .values: return "heart.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .math: return CQTheme.bluePrimary
        case .language: return CQTheme.purpleLanguage
        case .science: return CQTheme.greenSecondary
        case .values: return CQTheme.goldReligious
        }
    }
}

extension CurriculumCourse {
    static func course(for grade: CurriculumGrade) -> CurriculumCourse {
        guard let course = catalog.first(where: { $0.grade == grade }) else {
            preconditionFailure("Missing curriculum for grade \(grade)")
        }
        return course
    }
}

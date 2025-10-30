import Foundation
import SwiftUI

struct CurriculumSubjectPath: Identifiable {
    let subject: CurriculumSubject
    let storyline: String
    let levels: [CurriculumLevel]

    var id: CurriculumSubject { subject }
}

struct CurriculumLevel: Identifiable, Hashable {
    let id: UUID
    let title: String
    let grade: CurriculumGrade
    let focus: String
    let overview: String
    let questsRequiredForMastery: Int
    let quests: [CurriculumQuest]
    let reward: String

    init(
        id: UUID = UUID(),
        title: String,
        grade: CurriculumGrade,
        focus: String,
        overview: String,
        questsRequiredForMastery: Int,
        quests: [CurriculumQuest],
        reward: String
    ) {
        self.id = id
        self.title = title
        self.grade = grade
        self.focus = focus
        self.overview = overview
        self.questsRequiredForMastery = questsRequiredForMastery
        self.quests = quests
        self.reward = reward
    }
}

struct CurriculumQuest: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let checklist: [String]

    init(id: UUID = UUID(), name: String, description: String, checklist: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.checklist = checklist
    }
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

enum CurriculumSubject: String, CaseIterable, Identifiable {
    case math
    case language
    case science
    case values

    var id: String { rawValue }

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

enum CurriculumCatalog {
    static func subjectPath(for subject: CurriculumSubject) -> CurriculumSubjectPath {
        switch subject {
        case .math: return mathPath
        case .language: return languagePath
        case .science: return sciencePath
        case .values: return valuesPath
        }
    }

    static var totalLevelCount: Int {
        CurriculumSubject.allCases.reduce(into: 0) { result, subject in
            result += subjectPath(for: subject).levels.count
        }
    }

    static func indexOfFirstLevel(for grade: CurriculumGrade, subject: CurriculumSubject) -> Int? {
        let levels = subjectPath(for: subject).levels
        return levels.firstIndex { $0.grade == grade }
    }

    private static let mathPath = CurriculumSubjectPath(
        subject: .math,
        storyline: "Climb the Number Peaks to help the village keep its math clock running.",
        levels: [
            CurriculumLevel(
                title: "Counting Trail",
                grade: .preK,
                focus: "Counting and comparing groups within 10",
                overview: "Learners count critters, compare small sets, and build confidence with numbers to 10.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Meadow Count",
                        description: "Count animals in the meadow and match the total to numeral cards.",
                        checklist: [
                            "Count three groups of critters aloud",
                            "Match each group to the correct numeral",
                            "Explain which group has more or fewer"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Pattern Parade",
                        description: "Finish and create simple AB/ABB patterns with blocks.",
                        checklist: [
                            "Complete three unfinished patterns",
                            "Create a brand-new pattern using the blocks",
                            "Describe the pattern using words"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Snack Share",
                        description: "Compare plates of snacks to decide who has more and less.",
                        checklist: [
                            "Line up two plates and compare their totals",
                            "Use the words more, fewer, and same",
                            "Evenly share a plate between two friends"
                        ]
                    )
                ],
                reward: "Sticker: Meadow Helper"
            ),
            CurriculumLevel(
                title: "Number Bridge",
                grade: .kindergarten,
                focus: "Counting to 20 and early addition/subtraction stories",
                overview: "Learners extend counting, compose and decompose numbers, and solve picture stories.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Bridge Builder",
                        description: "Count planks to span a river and label each plank with numbers to 20.",
                        checklist: [
                            "Count from any start number up to 20",
                            "Place the numerals in order on the bridge",
                            "Skip-count by twos while crossing"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Snack Shop Stories",
                        description: "Solve addition and subtraction stories using counters.",
                        checklist: [
                            "Act out two add-to stories with counters",
                            "Act out two take-from stories with counters",
                            "Record each story using an equation"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Teen Number Towers",
                        description: "Build towers that show tens and ones in teen numbers.",
                        checklist: [
                            "Represent three teen numbers with towers",
                            "Explain how many tens and ones each has",
                            "Compare two towers and name the greater"
                        ]
                    )
                ],
                reward: "Badge: Bridge Architect"
            ),
            CurriculumLevel(
                title: "Addition Rapids",
                grade: .grade1,
                focus: "Addition and subtraction within 20",
                overview: "Learners solve equations, balance fact families, and use strategies for sums within 20.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Fact Family Raft",
                        description: "Use number bonds to complete fact family triangles.",
                        checklist: [
                            "Complete four fact family triangles",
                            "Explain how the facts are connected",
                            "Sort new facts into the correct family"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Strategy Stones",
                        description: "Solve sums using make-10 and doubles strategies.",
                        checklist: [
                            "Solve three make-10 problems",
                            "Solve three doubles or near-doubles",
                            "Share which strategy felt best"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Balance Boats",
                        description: "Balance equations by finding the missing addend.",
                        checklist: [
                            "Fill in three missing-number equations",
                            "Check each solution with subtraction",
                            "Create one new balance problem"
                        ]
                    )
                ],
                reward: "Tool: Fact Raft"
            ),
            CurriculumLevel(
                title: "Place Value Ridge",
                grade: .grade2,
                focus: "Place value to 1,000 and addition/subtraction within 100",
                overview: "Learners regroup tens and hundreds, solve word problems, and use number lines.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Base-Ten Camp",
                        description: "Represent 3-digit numbers with models and expanded form.",
                        checklist: [
                            "Build three numbers with base-ten blocks",
                            "Write the expanded form for each",
                            "Compare two numbers using >, <, ="
                        ]
                    ),
                    CurriculumQuest(
                        name: "Mountain Mail",
                        description: "Solve two-step word problems for the ranger station.",
                        checklist: [
                            "Solve three two-step problems",
                            "Explain which operation was used each time",
                            "Check one answer using a different strategy"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Number Line Trek",
                        description: "Use open number lines to add and subtract within 100.",
                        checklist: [
                            "Add two numbers using jumps on a line",
                            "Subtract two numbers using jumps back",
                            "Describe how the jumps connect to place value"
                        ]
                    )
                ],
                reward: "Title: Ridge Navigator"
            ),
            CurriculumLevel(
                title: "Multiplication Forest",
                grade: .grade3,
                focus: "Multiplication and division facts within 100",
                overview: "Learners build arrays, explore equal groups, and relate multiplication to division.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Array Orchard",
                        description: "Plant tree arrays to represent facts.",
                        checklist: [
                            "Create four arrays for given facts",
                            "Write the related equations",
                            "Rotate an array and explain why the product stays the same"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Group Gathering",
                        description: "Use equal groups to solve multiplication stories.",
                        checklist: [
                            "Act out three grouping stories",
                            "Draw a picture or bar model for each",
                            "Write the inverse division fact"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Fact Quest",
                        description: "Play a timed fact chase to build fluency.",
                        checklist: [
                            "Complete a 2-minute fact run with 90% accuracy",
                            "Record three facts that were tricky",
                            "Practice the tricky facts with skip-counting"
                        ]
                    )
                ],
                reward: "Companion: Fact Fox"
            ),
            CurriculumLevel(
                title: "Fraction Glaciers",
                grade: .grade4,
                focus: "Fractions, multi-digit multiplication, and measurement",
                overview: "Learners compare fractions, multiply multi-digit numbers, and solve measurement problems.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Fraction Flags",
                        description: "Design camp flags showing equivalent fractions.",
                        checklist: [
                            "Create three equivalent fraction sets",
                            "Place each on a number line",
                            "Explain how you know the fractions match"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Trail Supplies",
                        description: "Multiply multi-digit numbers to stock the trail store.",
                        checklist: [
                            "Solve two 2-digit by 2-digit problems",
                            "Solve one 3-digit by 1-digit problem",
                            "Estimate each product to check"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Ranger Timelines",
                        description: "Solve elapsed time problems using number lines.",
                        checklist: [
                            "Map out two elapsed time scenarios",
                            "Explain how to convert minutes to hours",
                            "Create one new problem for a friend"
                        ]
                    )
                ],
                reward: "Badge: Glacier Guide"
            ),
            CurriculumLevel(
                title: "Ratio Summit",
                grade: .grade5,
                focus: "Decimals, fractions operations, and volume",
                overview: "Learners add/subtract fractions with like denominators, multiply fractions, and work with decimals.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Trail Mix Lab",
                        description: "Add and subtract fractions to follow recipes.",
                        checklist: [
                            "Adjust three recipes by adding fractions",
                            "Subtract ingredients to scale down",
                            "Check answers using benchmarks"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Decimal Dashes",
                        description: "Place decimals on number lines and compare them.",
                        checklist: [
                            "Plot decimals to the hundredths place",
                            "Use >, <, = to compare five pairs",
                            "Convert one decimal to a fraction"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Campsite Volume",
                        description: "Calculate volume of rectangular prisms.",
                        checklist: [
                            "Find volume for three prisms",
                            "Explain the formula in your own words",
                            "Design a prism that meets a volume target"
                        ]
                    )
                ],
                reward: "Tool: Ratio Compass"
            ),
            CurriculumLevel(
                title: "Algebra Skyline",
                grade: .grade6,
                focus: "Ratios, expressions, and data displays",
                overview: "Learners write expressions, analyze ratios, and summarize data sets.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Market Ratios",
                        description: "Solve ratio tables and unit rate problems.",
                        checklist: [
                            "Complete two ratio tables",
                            "Find unit rates in three contexts",
                            "Explain one ratio using words"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Expression Elevators",
                        description: "Write and evaluate expressions with variables.",
                        checklist: [
                            "Translate three verbal phrases to expressions",
                            "Evaluate each expression for two values",
                            "Identify terms and coefficients"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Data Observatory",
                        description: "Create dot plots and histograms to describe data.",
                        checklist: [
                            "Collect or use a provided data set",
                            "Draw a dot plot and a histogram",
                            "Write two observations about the data"
                        ]
                    )
                ],
                reward: "Title: Skyline Analyst"
            )
        ]
    )

    private static let languagePath = CurriculumSubjectPath(
        subject: .language,
        storyline: "Restore the Story Grove by mastering phonics, fluency, and writing.",
        levels: [
            CurriculumLevel(
                title: "Alphabet Meadow",
                grade: .preK,
                focus: "Letter recognition and sound awareness",
                overview: "Learners identify letters, match sounds, and build first name recognition.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Letter Hunt",
                        description: "Search the meadow for uppercase and lowercase pairs.",
                        checklist: [
                            "Match ten letters to their lowercase partner",
                            "Name the sound for five letters",
                            "Build your name with letter cards"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Sound Picnic",
                        description: "Sort picnic foods by beginning sound.",
                        checklist: [
                            "Sort eight foods into sound baskets",
                            "Name a new word for two baskets",
                            "Clap the syllables for three foods"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Story Stretch",
                        description: "Retell a simple picture story with beginning, middle, end.",
                        checklist: [
                            "Name the characters",
                            "Describe what happened first, next, last",
                            "Share your favorite part"
                        ]
                    )
                ],
                reward: "Sticker: Story Sprout"
            ),
            CurriculumLevel(
                title: "Phonics Brook",
                grade: .kindergarten,
                focus: "Short vowels, sight words, and sentence building",
                overview: "Learners decode CVC words, write simple sentences, and read emergent text.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Word Builders",
                        description: "Blend sounds to build CVC words with tiles.",
                        checklist: [
                            "Blend six CVC words",
                            "Swap the first sound to make a new word",
                            "Sort words by vowel sound"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Sight Word Steps",
                        description: "Read and write high-frequency words.",
                        checklist: [
                            "Read a stack of ten sight words",
                            "Write each word in a sentence",
                            "Play a quick flash-card game"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Sentence Garden",
                        description: "Build sentences with capital letters and periods.",
                        checklist: [
                            "Arrange word cards to make three sentences",
                            "Rewrite one sentence with handwriting practice",
                            "Illustrate your favorite sentence"
                        ]
                    )
                ],
                reward: "Badge: Brook Reader"
            ),
            CurriculumLevel(
                title: "Reading Rail",
                grade: .grade1,
                focus: "Fluency, story elements, and opinion writing",
                overview: "Learners retell stories, identify characters and settings, and write short opinions.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Fluency Train",
                        description: "Practice reading a passage aloud with expression.",
                        checklist: [
                            "Read the passage three times",
                            "Record words that were tricky",
                            "Perform the passage for a listener"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Story Stop",
                        description: "Identify characters, setting, and key events.",
                        checklist: [
                            "Complete a story map",
                            "Retell the story using first, next, then, last",
                            "Name the problem and solution"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Opinion Post",
                        description: "Write a short opinion paragraph.",
                        checklist: [
                            "State your opinion in the first sentence",
                            "Give two reasons with details",
                            "Wrap up with a closing sentence"
                        ]
                    )
                ],
                reward: "Tool: Story Map"
            ),
            CurriculumLevel(
                title: "Chapter Crossing",
                grade: .grade2,
                focus: "Fables, main idea, and informative writing",
                overview: "Learners find main ideas, describe character lessons, and write facts.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Fable Ferry",
                        description: "Read fables and explain the moral.",
                        checklist: [
                            "List the characters in two fables",
                            "Describe the lesson each character learns",
                            "Connect a moral to a real-life example"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Main Idea Markers",
                        description: "Identify main idea and key details in nonfiction.",
                        checklist: [
                            "Highlight the main idea sentence",
                            "List three supporting details",
                            "Summarize the passage in two sentences"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Fact Builder",
                        description: "Write an informative paragraph with topic sentence and facts.",
                        checklist: [
                            "Choose a topic and gather three facts",
                            "Write using a topic sentence and detail sentences",
                            "Add a closing sentence"
                        ]
                    )
                ],
                reward: "Companion: Fact Owl"
            ),
            CurriculumLevel(
                title: "Reading Rapids",
                grade: .grade3,
                focus: "Text structure, vocabulary, and narrative writing",
                overview: "Learners compare texts, determine meaning of unknown words, and craft narratives with dialogue.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Structure Scout",
                        description: "Compare cause-and-effect and sequence passages.",
                        checklist: [
                            "Identify signal words in two texts",
                            "Create a graphic organizer for each",
                            "Explain how structure changes the message"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Word Explorer",
                        description: "Use context clues and prefixes to determine word meaning.",
                        checklist: [
                            "Define five words using context",
                            "Sort words by prefix meaning",
                            "Create a mini-glossary"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Narrative Rapids",
                        description: "Write a narrative with beginning, middle, end, and dialogue.",
                        checklist: [
                            "Brainstorm characters and setting",
                            "Draft the problem, rising action, and solution",
                            "Add dialogue with quotation marks"
                        ]
                    )
                ],
                reward: "Badge: Rapids Author"
            ),
            CurriculumLevel(
                title: "Literary Lighthouse",
                grade: .grade4,
                focus: "Theme, point of view, and research writing",
                overview: "Learners analyze theme, compare first- and third-person narrators, and write multi-paragraph reports.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Theme Signals",
                        description: "Identify themes in myths and poems.",
                        checklist: [
                            "Note key details that suggest theme",
                            "State the theme in a single sentence",
                            "Explain how the characters support the theme"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Perspective Patrol",
                        description: "Compare point of view between two texts.",
                        checklist: [
                            "Identify narrator clues",
                            "Explain how point of view changes the story",
                            "Rewrite a paragraph from a new perspective"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Research Beacon",
                        description: "Write a research report with cited sources.",
                        checklist: [
                            "Gather facts from two sources",
                            "Organize notes into sections",
                            "Draft, revise, and include a source list"
                        ]
                    )
                ],
                reward: "Title: Lighthouse Scholar"
            ),
            CurriculumLevel(
                title: "Argument Avenue",
                grade: .grade5,
                focus: "Comparing multiple accounts and opinion essays",
                overview: "Learners analyze differing viewpoints, support claims with evidence, and present speeches.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Eyewitness Files",
                        description: "Compare two accounts of the same event.",
                        checklist: [
                            "Record similarities and differences",
                            "Judge which details are most reliable",
                            "Explain why two accounts might disagree"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Evidence Workshop",
                        description: "Plan an opinion essay with clear reasons and evidence.",
                        checklist: [
                            "State a claim and three reasons",
                            "Match each reason with text evidence",
                            "Draft an engaging introduction"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Voice Share",
                        description: "Deliver a short persuasive speech.",
                        checklist: [
                            "Practice using transitions",
                            "Maintain eye contact and pacing",
                            "Reflect on audience feedback"
                        ]
                    )
                ],
                reward: "Tool: Debate Deck"
            ),
            CurriculumLevel(
                title: "Literacy Summit",
                grade: .grade6,
                focus: "Claims, evidence, and literary analysis",
                overview: "Learners trace arguments, analyze how chapters build, and write literary essays.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Argument Analyzer",
                        description: "Trace arguments in nonfiction and identify counterclaims.",
                        checklist: [
                            "Record the author's claim",
                            "List supporting reasons and evidence",
                            "Identify a counterclaim and rebuttal"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Structure Sleuth",
                        description: "Analyze how scenes or stanzas build meaning.",
                        checklist: [
                            "Break a chapter into key scenes",
                            "Explain how each scene moves the plot",
                            "Connect one scene to the theme"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Literary Essay",
                        description: "Write an essay comparing two texts on a shared theme.",
                        checklist: [
                            "Draft a thesis statement",
                            "Use textual evidence from both works",
                            "Conclude by synthesizing insights"
                        ]
                    )
                ],
                reward: "Title: Summit Author"
            )
        ]
    )

    private static let sciencePath = CurriculumSubjectPath(
        subject: .science,
        storyline: "Travel through the Discovery Biomes to investigate the natural world.",
        levels: [
            CurriculumLevel(
                title: "Senses Grove",
                grade: .preK,
                focus: "Five senses and nature observation",
                overview: "Learners explore sensory stations and practice describing observations.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Sound Safari",
                        description: "Identify animal and environment sounds.",
                        checklist: [
                            "Match five sounds to the correct picture",
                            "Describe how the sound made you feel",
                            "Share which sense helped the most"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Texture Trail",
                        description: "Sort objects by texture and observe with magnifiers.",
                        checklist: [
                            "Sort objects into smooth, rough, bumpy",
                            "Describe each using two adjectives",
                            "Draw one object you observed"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Weather Watch",
                        description: "Track the weather for three days.",
                        checklist: [
                            "Identify sky conditions",
                            "Record temperature using a simple thermometer",
                            "Choose clothing for each day"
                        ]
                    )
                ],
                reward: "Sticker: Sense Detective"
            ),
            CurriculumLevel(
                title: "Habitat Marsh",
                grade: .kindergarten,
                focus: "Animals, plants, and local weather patterns",
                overview: "Learners classify living things, track weather, and care for classroom plants.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Living vs. Non-living",
                        description: "Sort items collected on a nature walk.",
                        checklist: [
                            "Decide if each item is living, once-living, or non-living",
                            "Explain the reason for each choice",
                            "Sketch one plant and one animal"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Weather Station",
                        description: "Chart daily weather data and compare across a week.",
                        checklist: [
                            "Measure temperature and precipitation",
                            "Create a weather pictograph",
                            "Predict tomorrow's weather based on the chart"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Plant Care",
                        description: "Care for seedlings in the classroom garden.",
                        checklist: [
                            "Record plant height twice a week",
                            "Describe plant needs (water, sun, soil)",
                            "Share a tip for keeping plants healthy"
                        ]
                    )
                ],
                reward: "Badge: Habitat Helper"
            ),
            CurriculumLevel(
                title: "Sky Lab",
                grade: .grade1,
                focus: "Patterns of the sun, moon, and stars",
                overview: "Learners observe the sky, model day/night, and track seasonal patterns.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Shadow Tracker",
                        description: "Measure how a shadow changes during the day.",
                        checklist: [
                            "Record shadow length in the morning and afternoon",
                            "Explain why the shadow changed",
                            "Create a simple sun model"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Moon Journal",
                        description: "Sketch moon phases for two weeks.",
                        checklist: [
                            "Draw the moon each night",
                            "Sequence the drawings",
                            "Describe the repeating pattern"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Season Sort",
                        description: "Match animal behaviors and weather to seasons.",
                        checklist: [
                            "Sort cards into season categories",
                            "Explain how animals prepare for a season",
                            "Write a sentence about your favorite season"
                        ]
                    )
                ],
                reward: "Tool: Star Viewer"
            ),
            CurriculumLevel(
                title: "Forces Workshop",
                grade: .grade2,
                focus: "Pushes, pulls, and changes in motion",
                overview: "Learners plan investigations about motion and design simple solutions.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Ramp Races",
                        description: "Test how surface and slope affect speed.",
                        checklist: [
                            "Plan the test using fair rules",
                            "Record three trials with data",
                            "Share conclusions using evidence"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Balloon Rockets",
                        description: "Design a rocket to carry a paper astronaut across a line.",
                        checklist: [
                            "Sketch the design",
                            "Test and refine the rocket",
                            "Explain how air pushes the rocket"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Magnet Mystery",
                        description: "Investigate which materials are magnetic.",
                        checklist: [
                            "Test at least five materials",
                            "Record yes/no results",
                            "Describe a real-world use for magnets"
                        ]
                    )
                ],
                reward: "Companion: Motion Bot"
            ),
            CurriculumLevel(
                title: "Ecosystem Expedition",
                grade: .grade3,
                focus: "Life cycles, food webs, and traits",
                overview: "Learners model life cycles, build food chains, and explore inherited traits.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Life Cycle Lab",
                        description: "Compare the life cycles of two organisms.",
                        checklist: [
                            "Create diagrams for each life cycle",
                            "Highlight similarities and differences",
                            "Explain how each stage helps survival"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Food Web Builder",
                        description: "Construct a food web for a chosen habitat.",
                        checklist: [
                            "List producers, consumers, and decomposers",
                            "Draw arrows to show energy flow",
                            "Describe what happens if one species disappears"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Trait Detective",
                        description: "Classify traits as inherited or learned.",
                        checklist: [
                            "Sort trait cards",
                            "Interview a family member about traits",
                            "Share one trait you would like to learn"
                        ]
                    )
                ],
                reward: "Badge: Ecosystem Explorer"
            ),
            CurriculumLevel(
                title: "Energy Lab",
                grade: .grade4,
                focus: "Energy transfer and waves",
                overview: "Learners explore light, sound, and electric circuits through experiments.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Light Paths",
                        description: "Investigate reflection and refraction with mirrors and water.",
                        checklist: [
                            "Predict what will happen before testing",
                            "Record observations with diagrams",
                            "Explain the difference between reflection and refraction"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Sound Signals",
                        description: "Build devices to communicate using patterns of sound.",
                        checklist: [
                            "Design a sound pattern using vibrations",
                            "Test the signal with a partner",
                            "Revise the design to improve clarity"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Circuit Challenge",
                        description: "Create series and parallel circuits.",
                        checklist: [
                            "Draw a circuit diagram",
                            "Build and test the circuit",
                            "Explain how energy moves through the circuit"
                        ]
                    )
                ],
                reward: "Title: Energy Engineer"
            ),
            CurriculumLevel(
                title: "Earth Systems Summit",
                grade: .grade5,
                focus: "Earth's systems and human impact",
                overview: "Learners model Earth's systems, analyze weather data, and design solutions for environmental challenges.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Spheres Model",
                        description: "Create models showing interactions of geosphere, hydrosphere, atmosphere, biosphere.",
                        checklist: [
                            "Illustrate each sphere",
                            "Explain two interactions between spheres",
                            "Describe how humans impact one interaction"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Storm Data Lab",
                        description: "Analyze weather maps and graph trends.",
                        checklist: [
                            "Interpret a weather map",
                            "Graph temperature or precipitation across five days",
                            "Predict future weather using evidence"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Impact Innovators",
                        description: "Propose a solution to reduce human impact on an ecosystem.",
                        checklist: [
                            "Identify a local environmental issue",
                            "Design a solution with labeled diagram",
                            "Explain how the solution helps the ecosystem"
                        ]
                    )
                ],
                reward: "Tool: Eco Blueprint"
            ),
            CurriculumLevel(
                title: "STEM Observatory",
                grade: .grade6,
                focus: "Cells, energy transfer, and Earth in space",
                overview: "Learners model cells, investigate energy in ecosystems, and explore Earth's place in the universe.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Cell City",
                        description: "Model animal and plant cells and describe organelle functions.",
                        checklist: [
                            "Construct models for both cell types",
                            "Label each organelle and function",
                            "Compare similarities and differences"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Energy Flow Lab",
                        description: "Analyze energy transfer through ecosystems.",
                        checklist: [
                            "Create an energy pyramid",
                            "Calculate energy transfer between levels",
                            "Discuss factors that disrupt the flow"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Solar System Survey",
                        description: "Investigate scale and motion within the solar system.",
                        checklist: [
                            "Model orbital paths",
                            "Explain day/night and seasons",
                            "Compare planets using gathered data"
                        ]
                    )
                ],
                reward: "Title: Observatory Scholar"
            )
        ]
    )

    private static let valuesPath = CurriculumSubjectPath(
        subject: .values,
        storyline: "Guide the Harmony Village through character quests and community missions.",
        levels: [
            CurriculumLevel(
                title: "Kindness Corner",
                grade: .preK,
                focus: "Sharing, turn-taking, and feelings",
                overview: "Learners identify feelings, practice sharing, and use words to solve small problems.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Feelings Garden",
                        description: "Match faces to feeling words and act them out.",
                        checklist: [
                            "Name feelings for six faces",
                            "Act out a feeling using your body",
                            "Share a strategy to feel calm"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Sharing Picnic",
                        description: "Practice turn-taking with toys and snacks.",
                        checklist: [
                            "Model asking for a turn",
                            "Suggest a fair sharing plan",
                            "Reflect on how sharing made others feel"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Kind Words",
                        description: "Use sentence starters to solve playground problems.",
                        checklist: [
                            "Role-play two conflict scenarios",
                            "Choose kind words to help",
                            "Draw a picture of the solution"
                        ]
                    )
                ],
                reward: "Sticker: Harmony Heart"
            ),
            CurriculumLevel(
                title: "Friendship Lane",
                grade: .kindergarten,
                focus: "Cooperation, honesty, and empathy",
                overview: "Learners role-play friendship choices, practice honesty, and listen with empathy.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Team Builders",
                        description: "Complete tasks that require cooperation.",
                        checklist: [
                            "Plan a tower build with a partner",
                            "Take turns adding pieces",
                            "Share how teamwork helped"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Truth Detectives",
                        description: "Decide what to do when mistakes happen.",
                        checklist: [
                            "Listen to a short scenario",
                            "Explain why telling the truth matters",
                            "Practice apologizing and fixing the mistake"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Empathy Ears",
                        description: "Practice listening and reflecting feelings.",
                        checklist: [
                            "Listen to a classmate share a story",
                            "Reflect back what you heard",
                            "Offer a kind response"
                        ]
                    )
                ],
                reward: "Badge: Friendship Ally"
            ),
            CurriculumLevel(
                title: "Community Square",
                grade: .grade1,
                focus: "Rules, responsibilities, and community helpers",
                overview: "Learners explain classroom responsibilities, identify helpers, and create thank-you messages.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Rule Builders",
                        description: "Create posters explaining why rules keep us safe.",
                        checklist: [
                            "List three important rules",
                            "Explain the reason for each",
                            "Design a poster to teach younger students"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Helper Spotlight",
                        description: "Research community helpers and their tools.",
                        checklist: [
                            "Choose a helper to interview or research",
                            "List three responsibilities",
                            "Create a thank-you card"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Responsibility Chart",
                        description: "Track a personal responsibility for one week.",
                        checklist: [
                            "Choose a responsibility",
                            "Record success each day",
                            "Reflect on what helped you remember"
                        ]
                    )
                ],
                reward: "Companion: Helper Firefly"
            ),
            CurriculumLevel(
                title: "Courage Trail",
                grade: .grade2,
                focus: "Problem solving, perseverance, and respect",
                overview: "Learners practice growth mindset, respect differences, and solve peer conflicts.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Growth Garden",
                        description: "Learn phrases that show perseverance.",
                        checklist: [
                            "Sort fixed vs. growth mindset phrases",
                            "Create a personal perseverance plan",
                            "Share a time you kept trying"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Respect Rally",
                        description: "Celebrate similarities and differences in classmates.",
                        checklist: [
                            "Interview a classmate",
                            "Find two things you share and two that are different",
                            "Design a mini-poster celebrating diversity"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Peace Path",
                        description: "Use a simple conflict-resolution script.",
                        checklist: [
                            "Role-play the peace path steps",
                            "Practice using I-statements",
                            "Reflect on how the solution felt"
                        ]
                    )
                ],
                reward: "Badge: Courage Keeper"
            ),
            CurriculumLevel(
                title: "Citizenship Harbor",
                grade: .grade3,
                focus: "Local government, rights, and responsibilities",
                overview: "Learners explore community rules, volunteerism, and how citizens make a difference.",
                questsRequiredForMastery: 2,
                quests: [
                    CurriculumQuest(
                        name: "Civic Map",
                        description: "Map the services in your community.",
                        checklist: [
                            "List five community services",
                            "Identify who provides each service",
                            "Share how citizens can help"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Volunteer Vision",
                        description: "Plan a simple service project for school or neighborhood.",
                        checklist: [
                            "Choose a cause",
                            "List materials or helpers needed",
                            "Explain how the project benefits others"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Rights & Rules",
                        description: "Explain how rules protect rights.",
                        checklist: [
                            "Match rights with the rules that protect them",
                            "Discuss what happens if rules are broken",
                            "Role-play solving a community issue"
                        ]
                    )
                ],
                reward: "Tool: Civic Journal"
            ),
            CurriculumLevel(
                title: "Heritage Ridge",
                grade: .grade4,
                focus: "State history, cultural heritage, and ethics",
                overview: "Learners research state history, analyze historical choices, and celebrate traditions.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Timeline Trail",
                        description: "Build a timeline of key state events.",
                        checklist: [
                            "Select five significant events",
                            "Describe the impact of each event",
                            "Identify whose voices were missing"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Heritage Spotlight",
                        description: "Interview a family member or community elder about traditions.",
                        checklist: [
                            "Prepare respectful questions",
                            "Record traditions or celebrations",
                            "Share how traditions teach values"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Ethics Forum",
                        description: "Debate a historical decision from multiple perspectives.",
                        checklist: [
                            "Identify the decision and stakeholders",
                            "List possible choices and consequences",
                            "State your opinion with supporting reasons"
                        ]
                    )
                ],
                reward: "Badge: Heritage Guide"
            ),
            CurriculumLevel(
                title: "Leadership Lookout",
                grade: .grade5,
                focus: "U.S. government, media literacy, and collaborative leadership",
                overview: "Learners analyze founding documents, evaluate sources, and practice collaborative decision making.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Government Blueprint",
                        description: "Explain the three branches of government using a graphic.",
                        checklist: [
                            "Describe each branch's job",
                            "Give an example of checks and balances",
                            "Explain why separation of powers matters"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Source Detective",
                        description: "Evaluate the reliability of news and online sources.",
                        checklist: [
                            "Check author credentials",
                            "Distinguish fact from opinion",
                            "Identify persuasive techniques"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Leadership Council",
                        description: "Work in a team to solve a school issue.",
                        checklist: [
                            "Assign roles and responsibilities",
                            "Use consensus or voting to decide",
                            "Reflect on how the team collaborated"
                        ]
                    )
                ],
                reward: "Tool: Leadership Lanyard"
            ),
            CurriculumLevel(
                title: "Global Harmony",
                grade: .grade6,
                focus: "Global citizenship, ethics, and social impact",
                overview: "Learners research global issues, evaluate ethical dilemmas, and design service projects.",
                questsRequiredForMastery: 3,
                quests: [
                    CurriculumQuest(
                        name: "Global Issue Brief",
                        description: "Research a global challenge such as clean water or education access.",
                        checklist: [
                            "Gather facts from at least two credible sources",
                            "Explain the root causes and affected communities",
                            "Suggest one feasible action"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Ethics Lab",
                        description: "Debate a scenario with multiple stakeholders.",
                        checklist: [
                            "Identify the stakeholders and their viewpoints",
                            "Discuss short- and long-term consequences",
                            "Decide on an ethical action and justify it"
                        ]
                    ),
                    CurriculumQuest(
                        name: "Impact Project",
                        description: "Design a service project plan that could be carried out locally.",
                        checklist: [
                            "State the project goal and audience",
                            "Outline steps, materials, and timeline",
                            "Describe how success will be measured"
                        ]
                    )
                ],
                reward: "Title: Harmony Ambassador"
            )
        ]
    )
}

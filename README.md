# Agent Skills & Workflows

A centralized collection of **Skills**, **Workflows**, and **Rules** for AI coding agents. This repository is designed to be your **Master Source** for all AI capabilities.

## Architecture

This repository uses a standardized `.agent` directory structure:

```text
agent-skills/
├── .agent/
│   ├── skills/       # Packaged capabilities (e.g., Security Scan, React Best Practices)
│   ├── workflows/    # Standard operating procedures (e.g., "Brainstorm", "Review")
│   └── rules/        # Global rules for your agents
├── deploy-skills.sh  # Script to sync to Agents or Projects
└── sync-common.sh    # Script for internal shared resource management
```

## Setup & Deployment

You can use this repository in two ways:

### 1. Central Hub for Agents (Local)
Keep all your agents (Claude, Cursor, Windsurf, etc.) in sync with the latest skills.

**Installation**:
```bash
# 1. Clone this repository
git clone https://github.com/EasonLiu0913/agent-skills.git
cd agent-skills

# 2. Deploy to all your local agents
./deploy-skills.sh
```

**What happens?**
The script creates symbolic links from this repo to your agents' configuration directories. Any change you make here is immediately reflected in all agents.

### 2. Project Integration (Project Mode)
Inject your skills and workflows into a specific project to give it "Superpowers".

**Usage**:
```bash
# Go to your target project directory
cd ~/Documents/MyNewProject

# Run the deployment script pointing to current directory (.)
~/Documents/PROJECTS/agent-skills/deploy-skills.sh .
```

**What happens?**
The script links the entire `.agent` folder to your project. Your project now has access to:
- **Workflows**: Run `/superpowers-brainstorm` or `/superpowers-review` directly.
- **Rules**: Project-specific rules are applied.
- **Skills**: All skills are available for use.

## Available Capabilities

### 🛠️ Workflows
Common procedures to standardize your AI interaction:
- **/superpowers-brainstorm**: Structural analysis of problems (Goal/Constraints/Options).
- **/superpowers-plan**: Generate step-by-step implementation plans.
- **/superpowers-execute-plan**: Execute plans with verification steps.
- **/superpowers-review**: Comprehensive code review before commit.

### 🧩 Skills
- **react-best-practices**: Vercel's performance and optimization guidelines.
- **nextjs-security-scan**: Vulnerability scanner for Next.js apps.
- **web-design-guidelines**: UI/UX audit tool.
- **claude.ai**: Integration tools for Claude.

### 📝 Rules
- **superpowers.md**: Core rules for AI behavior (Plan Gate, TDD, etc.).

## Contribution

1. Create a new skill in `.agent/skills/<skill-name>`.
2. If sharing code, put it in `.agent/skills/_common` and use `sync-common.sh` to link it.
3. Run `./deploy-skills.sh` to update your agents.

## License

MIT

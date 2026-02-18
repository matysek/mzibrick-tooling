# Boomwhackers Skill Guide

## What is the Boomwhackers Skill?

The boomwhackers skill is a Claude Code plugin that enables Claude to automatically help you generate Boomwhacker play-along videos using natural language.

## How It Works

When working in this directory with Claude Code CLI, Claude will automatically recognize requests related to boomwhacker video generation and use the skill to help you.

## Usage Examples

### Automatic Skill Activation

Simply tell Claude what you want:

1. **"Create a boomwhacker video from a video file"**
   - Claude will activate the skill and run the appropriate commands

2. **"Generate a boomwhacker preview for my-song.mp3"**
   - Claude will use preview mode to generate a 10-second test

3. **"Make a falling notes visualization for this video file"**
   - Claude will process your local video file

4. **"Process my music with boomwhackers"**
   - Claude will guide you through the process

### Manual Skill Invocation

You can also invoke the skill directly:

```
/boomwhackers
```

This will provide Claude with all the knowledge about the boomwhackers system.

## What the Skill Provides

The skill gives Claude knowledge about:
- How to activate the virtual environment
- Command syntax for the boomwhackers script
- Preview vs. full video generation
- Troubleshooting common issues
- Input formats (YouTube URLs, local files)
- Output locations and filenames
- The WhackerHero patch
- Processing pipeline details

## Skill Triggers

The skill automatically activates when you mention:
- "boomwhacker video"
- "boomwhacker playalong"
- "falling notes video"
- "boomwhacker visualization"
- "play-along video"

## Benefits

- **No need to remember commands**: Just describe what you want
- **Automatic workflow**: Claude handles directory changes, venv activation, etc.
- **Context-aware**: Claude knows about the customizations and patches
- **Error handling**: Claude can help troubleshoot issues
- **Best practices**: Claude will suggest preview mode and proper workflows

## Skill Location

The skill is stored in:
```
.claude/plugins/boomwhackers-plugin/skills/boomwhackers/SKILL.md
```

## Customization

You can edit the SKILL.md file to:
- Add new trigger phrases
- Include additional examples
- Document project-specific workflows
- Add troubleshooting steps

## Example Session

```
You: Create a preview of the boomwhacker video for "Když jde malý bobr spát.webm"

Claude: I'll help you generate a boomwhacker preview for that video file.
[Claude activates the skill and runs the appropriate commands]
```

## Verifying the Skill is Loaded

When Claude Code starts, it should detect the plugin in `.claude/plugins/`. You can verify by asking:

```
You: What skills are available?
```

Claude should list the boomwhackers skill among others.

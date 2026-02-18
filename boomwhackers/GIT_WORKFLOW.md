# Git Workflow for Boomwhackers Project

## What Gets Committed

### ✅ Always Commit
- **Source code**: `song_add_boomwhackers_playalong.py`
- **Setup scripts**: `setup_env.sh`, `apply-whackerhero-patch.sh`
- **Patches**: `whackerhero-bigger-notes.patch`
- **Documentation**: `README.md`, `SKILL_GUIDE.md`, `GIT_WORKFLOW.md`
- **Claude plugin**: `.claude/plugins/boomwhackers-plugin/`
- **Git configuration**: `.gitignore`

### ❌ Never Commit (Automatically Ignored)
- **Virtual environment**: `venv_boomwhacker/`
- **Temp directory**: `bw_project_temp/`
- **Output videos**: `Final_Boomwhacker_Video.mp4`, `Preview_Boomwhacker_Video.mp4`
- **Generated MIDI**: `*.mid`, `*.midi`
- **Python cache**: `__pycache__/`, `*.pyc`
- **IDE files**: `.vscode/`, `.idea/`, `*.swp`
- **OS files**: `.DS_Store`, `Thumbs.db`
- **Debug/test files**: `issue-*.png`, `test_*.mp4`

### 🤔 Your Choice (Not Ignored)
- **Input videos/audio**: `*.webm`, `*.mp4`, `*.mp3`, etc.
  - Generally **not recommended** to commit (large files)
  - Use Git LFS if you need to track them
  - Keep them locally for testing

## Common Git Commands

### Check Status
```bash
git status
```

### Add Changes
```bash
# Add specific file
git add README.md

# Add all changes (be careful!)
git add .

# Check what would be ignored
git status --ignored
```

### Commit Changes
```bash
git commit -m "Description of changes"
```

### View What Would Be Committed
```bash
git diff --staged
```

## Current Repository State

After the recent changes:
```
Changes staged:
- .claude/plugins/boomwhackers-plugin/
- SKILL_GUIDE.md

Untracked (decide if you want to commit):
- .gitignore (should commit this!)
- Input video files (probably don't commit)

Ignored (never committed):
- venv_boomwhacker/
- bw_project_temp/
- Preview_Boomwhacker_Video.mp4
- Generated output videos
```

## Recommended Next Steps

1. **Add and commit the .gitignore**:
   ```bash
   git add .gitignore
   git commit -m "Add .gitignore for boomwhackers project"
   ```

2. **Commit the already staged Claude plugin files**:
   ```bash
   git commit -m "Add Claude Code skill for boomwhackers generation"
   ```

3. **Push to remote** (if applicable):
   ```bash
   git push
   ```

## Working with Large Files

If you need to track large video/audio files:

### Option 1: Don't Track Them
Keep them locally, ignore them in git. This is recommended.

### Option 2: Use Git LFS
```bash
# Install Git LFS
git lfs install

# Track specific file types
git lfs track "*.mp4"
git lfs track "*.webm"

# Commit the .gitattributes file
git add .gitattributes
git commit -m "Add Git LFS tracking"
```

## Cleaning Up

To remove already-tracked files that should be ignored:
```bash
# Remove from git but keep locally
git rm --cached file_to_ignore

# Commit the change
git commit -m "Remove file from tracking"
```

To clean ignored files from working directory:
```bash
# Preview what would be deleted
git clean -ndX

# Actually delete ignored files
git clean -fdX
```

## Best Practices

1. ✅ **Review before committing**: Use `git diff` and `git status`
2. ✅ **Write clear commit messages**: Describe what and why
3. ✅ **Commit frequently**: Small, logical changes
4. ✅ **Don't commit generated files**: Let .gitignore handle them
5. ✅ **Keep repository small**: Avoid large binary files when possible
6. ❌ **Don't use `git add .` blindly**: Review what you're adding
7. ❌ **Don't commit secrets**: No API keys, passwords, etc.

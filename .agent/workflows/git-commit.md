---
description: Intelligent Git Commit & Push Workflow
---

1. Check current git status
   - Run `git status` to see staged/unstaged changes
   - Run `git diff` (and `git diff --cached`) to understand the context of changes

2. Generate Commit Message
   - Analyze the diffs and summarize changes into a clear, structured commit message
   - **User Interaction**: Present the proposed commit message to the user for approval or edit.
   - *Wait for user confirmation*

3. Stage and Commit
   - Run `git add .` (or specific files if user requested)
   - Run `git commit -m "..."` using the agreed message

4. Push (Conditional)
   - Check the user's initial request for the keyword "push" (e.g., "commit and push", "commit push", or just "push" after changes)
   - **If "push" is present in the request**:
     - Run `git push` automatically
   - **If "push" is NOT present**:
     - Do not push. Just notify the user that commit is done.

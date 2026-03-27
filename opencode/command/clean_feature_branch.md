---
description: "How to clean up a feature branch before merging it into the main branch."
---

When working on a feature branch, it's important to keep it clean and organized before merging it into the main branch. Here are some steps you can take to clean up your feature branch:

0. **Commit and push your changes**: Make sure to commit all your changes before starting the cleanup process. This will help you keep track of your changes and make it easier to revert if needed.

1. **Rebase onto the latest main branch**: This will help you incorporate any changes that have been made to the main branch since you started working on your feature branch. Use the command `git pull --rebase origin [branch_name]` to do this. Check the correct branch name, as the `main` or `master` branches may not be the branch from which you branched off.

2. **Resolve any conflicts**: If there are any conflicts during the rebase, Git will pause and allow you to resolve them. Open the conflicting files, make the necessary changes, and then stage the resolved files using `git add [file_name]`. After resolving all conflicts, continue the rebase with `git rebase --continue`.

3. **Clean up commit history**: If your feature branch has a messy commit history, you can reset (softly) the working directory up to the first commit of feature branch while maintaining the current working tree and then create new commits that better represent the changes. Also, you can use rebase and squash/fixup  commits as needed. This will help create a cleaner and more concise commit history.

4. **Run local builds and tests**: Make sure to run all tests to ensure that your changes do not break any existing functionality. This will help you catch any issues before merging. Also, run the linters. This will help you catch any style issues before merging.

5. **Review your changes**: Take a moment to review your changes with the remote branch. Check that the cleaned-up commit history does not change anything important that was present in the original commits. Also, check that the code is clean and follows the coding standards of your project. 

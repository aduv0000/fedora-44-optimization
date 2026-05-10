# Contributing to Fedora 44 Optimization

First off, thank you for considering contributing! 🎉  
Whether you're fixing a bug, improving the documentation, or suggesting a new tweak, your help makes this project better for everyone.

## Table of Contents
- [Code of Conduct]
- [For Beginners: Your First Contribution]
- [For Experts: Development Setup]
- [Coding Standards & Conventions]
- [How to Submit Changes]
- [Feature Requests & Bug Reports]

## Code of Conduct
This project and everyone participating in it are governed by a simple rule: **Be respectful, be constructive, and be welcoming.** Harassment or dismissive behavior won't be tolerated. Let's keep this a positive space for learning and building.

## For Beginners: Your First Contribution
**Never contributed to open-source before? That's okay!**  
Here's the simplest way to help:

1.  **Find Something Small**: Look at the [Issues] tab for items labeled `good first issue` or `documentation`.
2.  **Edit Directly**: If it's a small text change, you can click the "Edit" (pencil) icon on the relevant file and make your changes right on GitHub.
3.  **Propose Your Change**: Scroll down, add a short description of what you changed, and click "Propose changes". We'll review it and merge it if it looks good.

## For Experts: Development Setup
To work on the script locally and test your changes:

1.  **Fork** the repository to your own GitHub account.
2.  **Clone** your fork to your local machine.
3.  **Test in a clean environment**: The best way to test is on a fresh Fedora 44 virtual machine or a disposable container.
4.  Run the existing script once as a baseline, then test your modified version to compare behavior.

## Coding Standards & Conventions
When modifying the script, please keep these principles in mind:

*   **`bash` syntax is required**. The script must run with standard `bash`.
*   **Keep it non-interactive**. Do not add prompts that require user input unless absolutely necessary. The script's purpose is to run unattended.
*   **Use `set -e` safety net**. The script should exit immediately if any command fails.
*   **Add clear comments**. Every section should have a descriptive comment block explaining what it does and why.
*   **Test on a clean install**. Always verify your changes don't break anything on a pristine Fedora 44 system.

## How to Submit Changes
1.  Create a new branch on your fork with a descriptive name (e.g., `fix-dnf-speed`, `add-gaming-tweaks`).
2.  Make your changes and commit them with a clear, short message.
3.  Push your branch to your fork on GitHub.
4.  Open a **Pull Request (PR)** to the `main` branch of the original `aduv0000/fedora-44-optimization` repository.
5.  In the PR description, explain **what** you did, **why** it's beneficial, and **how** you tested it.

A maintainer will review your PR, leave feedback if needed, and merge it when ready.

## Feature Requests & Bug Reports
*   **Bug Report**: Open a new [Issue] and include the error message, your hardware specs (RAM, CPU), and steps to reproduce.
*   **Feature Request**: Open a new [Issue] and describe the tweak, which hardware it helps, and any sources or benchmarks that support it.

## Questions?
If you don't understand something or need help, just open an [Issue] and ask. No question is too small.

# Practice exercise: the hackathon workflow on a tiny function

**Goal.** Do once, on a tiny problem, everything you will do in the hackathon: branch, implement a stub until
its tests pass, commit, push, open a PR. Takes about 20 minutes. Do it *before* the hackathon, in your own
fork or a copy of the repo.

Files:

- `template.R` – a stub `beta_cv(a, b)` with a `TODO`.
- `check.R` – a test file for it. Run with `Rscript practice/check.R` (or `testthat::test_file("practice/check.R")`).

Steps:

1. `git switch -c practice-<yourname>`
2. Open `practice/template.R`. Implement `beta_cv()` (the coefficient of variation of a Beta distribution: sd divided by mean).
3. Run `Rscript practice/check.R` until all tests pass. Read the failure messages: they tell you what you returned and what was expected.
4. Add **one test of your own** to `check.R` for a case you think matters.
5. `git add practice/template.R practice/check.R && git commit -m "Implement beta_cv"`
6. `git push -u origin practice-<yourname>`
7. On GitHub open a pull request into `main`, with the PR template filled in. Ask a classmate to review it. Do **not** merge it into the hackathon's `main` unless your instructor says so.

If something goes wrong, ask your instructor; nothing here can damage the hackathon code.

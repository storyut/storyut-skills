---
name: tldr
description: Summarize any URL, file, or pasted text into 5 sentences with the key takeaway bolded. Use when the user says summarize, TL;DR, too long, what is this, or pastes something long and asks what it's about.
---

Read the source (URL, file path, or pasted text). Produce exactly:

1. **5 sentences.** Not 4, not 6. The first sentence answers "what is this?" The rest cover what matters.
2. **Bold the one sentence** that is the takeaway — the thing you'd remember if you forgot the rest.
3. **A verdict line:** `Do I care? — <yes/no/maybe> — <one reason>.`

Nothing else. No headers, no bullet lists, no analysis, no follow-up questions.

**Completion criterion:** output is exactly 5 sentences + 1 verdict line. The bolded sentence is the single most important point.
# storyut-skills

[![version](https://img.shields.io/github/v/tag/storyut/storyut-skills?label=version)](https://github.com/storyut/storyut-skills/tags) [English](README.md)

给 Claude Code 用的 agent skills，外加一份持续维护的 OpenAI Codex 移植版。

## 安装

用 [`npx skills`](https://github.com/vercel-labs/skills)，会列出清单让你挑：

```bash
npx skills add storyut/storyut-skills
```

也可以只装其中几个，并且装到全局而不是当前项目：

```bash
npx skills add storyut/storyut-skills --skill 'tldr,brew' --global
```

18 个 skill 全部对外暴露，两套 fablely 都在内。Codex 移植版用带 `-codex` 后缀的名字发布（`fablely-codex`、`fablely-spec-codex`……），所以可以和 Claude Code 原版并存，不会互相顶掉。

其实也可以不用装。文件本身就是成品，clone 下来复制过去一样能跑：

```bash
git clone https://github.com/storyut/storyut-skills.git
cp -r storyut-skills/tldr ~/.claude/skills/
cp -r storyut-skills/fablely-skill/fablely .claude/skills/   # fablely 在下一层目录里
```

用的时候把名字当斜杠命令打出来就行（`/tldr`、`/brew`），或者直接描述你要干什么，让 agent 自己按 `description` 匹配。

## 里面有什么

### fablely 家族：项目连续性

这个 repo 存在的理由。长周期的活儿是被健忘症拖死的：会话被打断，上下文被压缩，下一个会话信心十足地重造一个已经有的东西，或者对着从没跑过的步骤报"已完成"。

fablely 的解法是把可信状态落到磁盘上的 `.fable/` 目录，只守一条规矩：**结论的强度不能超过你真正看到的证据。**"测试套件通过"意味着你亲眼看着它过了，而不是代码看上去没问题。

| Skill | 干什么 |
|---|---|
| [`fablely`](fablely-skill/fablely/SKILL.md) | 总调度。按规模给来的需求分流，跑工作单元的生命周期，卡住"先立意图再动手""先写 PROGRESS 再收工"。可以给项目铺一套 `.fable/`，也可以接管已有的。 |
| [`fablely-spec`](fablely-skill/fablely-spec/SKILL.md) | 把一个模糊需求收敛成一个定稿文件，设计、规格、计划写在一起。它只拷问你，不动手执行。 |
| [`fablely-arch`](fablely-skill/fablely-arch/SKILL.md) | 扫描*加深机会*：那些能把更多行为塞进更小接口的重构。给出排好序的候选，选中的交给 `fablely-spec`。 |
| [`fablely-ask`](fablely-skill/fablely-ask/SKILL.md) | 咨询车道。回答关于项目的问题，什么都不碰：不盖意图戳，不写 PROGRESS，不改文件。 |
| [`fablely-debug`](fablely-skill/fablely-debug/SKILL.md) | 对付硬骨头 bug 和性能回退的诊断循环。先搭出一个够快的反馈回路，再把它花在二分和假设验证上。可以单独用；项目里有 `.fable/` 时自动接进 fablely。 |

每个项目会拿到一份 `.fable/STANDARDS.md`，质量线以编号条款（`SEC-1`、`ERR-2`）写出来。这些条款在活儿被*设计*的时候就拿来对照，不是事后当闸门卡一道。没关掉的发现会挡住这个工作单元，直到它被修掉，或者被 `DECISIONS.md` 里一条可追溯的记录豁免。

#### 为什么要有 Codex 移植版

因为只能活在某一家工具里的连续性，算不上连续性。

fablely 的整个前提是项目状态存在磁盘上，不在上下文窗口里。这才是新会话能接上前一个会话死掉那一刻的原因。但如果这份状态只有 Claude Code 读得懂，你不过是把健忘症往上挪了一层：换 Codex 干一轮，早就定过的事又得重推一遍。何况模型会变，工具链的更迭比它们服务的项目快。

所以 `.fable/` 被当成一个冻结的、与工具无关的格式，两个移植版对它的读写完全一致。Claude Code 起的项目在 Codex 里能干净接上，反过来也一样。你可以中途切换，或者哪个更擅长眼前这活儿就用哪个，线索不会断。

不一样的只有非不一样不可的部分。Codex 版按 GPT-5.6 的路子重排过：结论先行，用决策规则替代脚手架，整体短了约三分之一。Codex 又没有生命周期 hook，所以在 Claude Code 里靠 hook 兜住的保证，这边改由 `AGENTS.md` 的正文承担。移植的是行为，不是措辞。差异都是有意为之，也[写在文档里](fablely-skill-codex/README.md)。

### 写作与思考

| Skill | 干什么 |
|---|---|
| [`brew`](brew/SKILL.md) | **元 skill。** 写一个新 skill，或者把已有的熬到"还撑得住原来行为的最少 token"。这个 repo 其余部分都是按它的风格写的。 |
| [`brainstorm`](brainstorm/SKILL.md) | 五五开的头脑风暴。agent 出大约一半的点子，轮流来，收敛之前不做评判。`--deep` 会加一轮并行的静默发散；`--auto` 把生成那一半整个接过去。 |
| [`fable-prompter`](fable-prompter/SKILL.md) | 把一个含糊的念头（"给这堆数据做点什么"）变成能上生产的 Claude Fable 5 提示词。含糊是预期输入，不是拿来抱怨的。 |
| [`be-a-human-zh`](be-a-human-zh/SKILL.md) | 写、改、重写中文，消灭 AI 味。硬性禁用词规则，不靠感觉。 |

### 日常

| Skill | 干什么 |
|---|---|
| [`ask`](ask/SKILL.md) | 只读地回答一个问题，来源是代码库 / 网页 / 官方文档。项目想强加什么流程，它一概不理。 |
| [`tldr`](tldr/SKILL.md) | 正好 5 句，一句加粗的要点，一行结论。不是 4 句，也不是 6 句。 |
| [`wakaranai`](wakaranai/SKILL.md) | 同一件事讲三遍：入门、熟手、专家。你自己挑真正需要的那个深度。 |
| [`wiztree-cleaner`](wiztree-cleaner/SKILL.md) | 读 WizTree 导出的 CSV 磁盘报告，提出哪些能安全删掉。只针对 Windows。 |

## 这些东西是怎么写的

如果你打算 fork 或者自己写，[`brew/SKILL.md`](brew/SKILL.md) 就是全部方法论，而且很短：

- **面向 agent 写。** 读者是在解析，不是在被说服。不要励志开场白，不要把任务复述一遍。
- **能撑住行为的最少 token。** 每一行都是每次调用都要付的上下文成本。细节该放进 `references/`，用链接挂上，需要时才加载。
- **`description` 就是触发器。** 它必须同时讲清这个 skill *做什么*和*什么时候用*，否则 agent 不会在该出手的时候出手。
- **`disable-model-invocation: true`**，用在那些只应该由人打出来才运行的 skill 上。

一个 skill 的目录结构：

```
<skill-name>/
  SKILL.md            # 必需，frontmatter + 指令正文
  references/         # 可选，按需加载
  templates/          # 可选，skill 写进你项目里的文件
```

## 说明

- fablely 系列分在 `fablely-skill/`（Claude Code）和 `fablely-skill-codex/`（Codex）两个目录下；独立 skill 就放在 repo 根目录。
- Codex 移植版在持续跟原版同步；已知的有意差异列在 [`fablely-skill-codex/README.md`](fablely-skill-codex/README.md)。
- `.claude-plugin/marketplace.json` 声明了这两套 fablely，`npx skills` 才找得到它们。这个 CLI 只往 repo 根目录下走一层，所以嵌在 `fablely-skill/<name>/` 里的 skill 不声明就是隐形的。文件里的路径**必须**以 `./` 开头，否则 CLI 会一声不吭地跳过整份清单。

## 版本

用 git tag 发版，整个 repo 共用一个版本号。大版本号变了，意味着这个 repo 之外有东西被弄坏了：要么 `.fable/` 的格式改了，做到一半的项目得迁移；要么某个 skill 被改名或删掉了，指着旧名字的安装和 `--skill` 参数会解析不到。次版本号是加了 skill 或者加了新行为。修订号就是改文字。

在意这个的话就 pin 一个 tag，`master` 是会动的。

## 许可

[MIT](LICENSE)。拿去用，随便 fork，看不顺眼的部分直接砍掉。

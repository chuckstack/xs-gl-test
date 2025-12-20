# Work Instruction

## TOC

- [Summary](#summary)
- [Document Maintenance Guidelines](#document-maintenance-guidelines)
- [DRY](#dry)
- [Documentation Style](#documentation-style)
- [Content Selection Guidelines](#content-selection-guidelines)
  - [What to Include](#what-to-include)
  - [What to Exclude](#what-to-exclude)
  - [Decision Framework](#decision-framework)
  - [Media Selection](#media-selection)
- [README](#readme)
  - [Purpose](#purpose)
  - [Structure](#structure)
  - [When to Create a README](#when-to-create-a-readme)
  - [Subdirectory README](#subdirectory-readme)
- [Work Instruction Types](#work-instruction-types)
  - [Principles](#principles)
  - [Roles](#roles)
  - [Tasks](#tasks)
  - [Tools](#tools)
  - [Example: Training-Enriched Role Documentation](#example-training-enriched-role-documentation)
- [Why Markdown](#why-markdown)
- [Markdown Document Structure](#markdown-document-structure)
- [Markdown Task Lists](#markdown-task-lists)
  - [Simple Task List Example](#simple-task-list-example)
  - [Hierarchical Task List Example](#hierarchical-task-list-example)
- [Document Naming Convention](#document-naming-convention)
- [Directory Structure](#directory-structure)
- [Tags](#tags)
- [Notes Warnings Tips References and Comments](#notes-warnings-tips-references-and-comments)

## Summary

The purpose of this document is to help the team write clear, concise and conformant work instructions. Reference this document when making changes to any work instructions in any repository. Adhere to the following 'Document Maintenance Guidelines' section.

## Document Maintenance Guidelines

The following are core principles of maintaining clear, concise anti-fragile and conformant work instructions:

- **DRY, Clear and concise**: Remove redundancy, focus on essential information and reference related information by name
- **Documentation Style**: Get to the point, discuss the big picture, share appropriate details and stay friendly
- **Consider AI in Content Creation**: Create material that can be directly applied and electrified by AI
- **Prioritize references over examples**: If work instructions exist, reference them (do not repeat them)
- **Avoid line number references**: Use searchable string references (e.g., "see Parameters Record Pattern")
- **Prefer search terms over file references**: use searchable string references instead direct file references when appropriate
- **Avoid numbered cross-references**: Reference sections by name, not number (e.g., "see UUID Pattern" not "see Pattern 13") - numbered references break when content is reordered
- **Current references only**: Remove historical context and deprecated approaches
- **Maintain TOC**: Update the table of contents when adding or removing major sections and only include ## and ### sections

## DRY

Go to great effort to "Don't Repeat Yourself" (DRY). Be kind, clear and concise.

## Documentation Style

Our goal is to speak to all operating styles in a way they wish to be communicated with. The following is a framework for accomplishing this goal.

- **Get the point**: Start with the phrase "The purpose of this ... is to ...". By simply stating this phrase, you will lower the tension of driving style users.
- **Big Picture**: Follow the purpose with "... is important because ...". By explaining "what's in it for them", we lower the tension of expressive style users.
- **Details**: After stating the what "point" and the why "picture", supply the needed details as is appropriate. By supplying appropriate details, we lower the tension of analytical style users.
- **Friendly**: Stay people friendly. Almost everyone likes it when we are friendly.

## Content Selection Guidelines

The purpose of this section is to help you decide what content to include or exclude from work instructions.

This is important because every word costs future maintenance effort. Write the minimum needed for success.

### What to Include

Include content that is **specific to your organization**:
- Your vocabulary and terminology
- Your specific process variations
- Your system configurations and settings
- Your role definitions and boundaries
- Your approval workflows and authorities
- Your specific business rules and policies

### What to Exclude

Exclude content that is **general knowledge or industry standard**:
- General concepts (e.g., "what is an invoice")
- Industry standard processes (e.g., "how accounting works")
- Tool vendor documentation (e.g., "how to use a spreadsheet")
- Widely available tutorials (e.g., "how to write markdown")

### Decision Framework

When writing, ask yourself:
1. **Is this unique to our organization?** → Include it
2. **Could AI answer this from general knowledge?** → Exclude it
3. **Does this explain HOW we do it differently?** → Include it
4. **Does this explain WHAT something is generally?** → Exclude it

### Media Selection

Choose media based on long-term maintenance cost:

**Words (preferred)**
- Use for: Processes, policies, rules, definitions
- Benefits: Easy to maintain, search, version, and AI-process
- Update frequency: Frequent updates manageable

**Pictures (use sparingly)**
- Use for: Complex spatial relationships, UI layouts when unavoidable
- Drawbacks: Outdated quickly, not easily searchable, harder to version
- Update frequency: Only if rarely changes

**Videos (avoid unless critical)**
- Use for: One-time events/scenarios like initial launch demonstrations
- Drawbacks: Highest maintenance cost, most difficult to search or version
- Update frequency: Often impractical to maintain

## README

README documents serve a specific purpose in work instruction documentation: **concepts and discovery, not implementation details**.

### Purpose

**Focus on the "why" and "when", not the "how":**
- Module/directory purpose and organizational integration
- Conceptual overview of what problem it solves
- Quick start examples showing typical usage patterns
- Links to detailed work instructions (roles, tasks, tools)

**Implementation details belong in work instructions:**
- Detailed step-by-step procedures → Task documents
- Specific tool usage and parameters → Tool documents
- Responsibilities and boundaries → Role documents

### Structure

```markdown
# [Directory/Module Name]

Brief description of purpose and integration (2-3 sentences).

## Quick Start

[Simple example showing most common usage]

## Work Instructions

- [Link to relevant role documents]
- [Link to relevant task documents]
- [Link to relevant tool documents]

## Related Documentation

[Links to external references or related modules]
```

### When to Create a README

Create a README when a directory contains multiple work instructions that need:
- Conceptual grouping and context
- Quick start guidance for new users
- Navigation help to find the right work instruction

Don't create a README for:
- Single work instruction files (the document itself is sufficient)
- Directories with self-explanatory structure
- Content that would just duplicate work instruction summaries

### Subdirectory README

The purpose of subdirectory READMEs is to prevent parent READMEs from becoming too large by moving detailed content into focused child documents.

This is important because it keeps navigation simple while preserving access to detailed information when needed.

**When to create a subdirectory README:**
- Parent README exceeds 200 lines
- Subdirectory has significantly different scope than parent
- Subdirectory needs detailed context that would clutter parent

**Parent-Child relationship:**
- **Parent README**: Overview and references to subdirectories
- **Child README**: Detailed content specific to subdirectory
- Parent references child: "See [subdirectory/README.md](subdirectory/README.md) for details"
- Child does NOT reference parent (hierarchy is one-way)

**DRY principle:**
- Do not repeat content between parent and child
- Parent provides overview, child provides details
- Child assumes reader has read parent context

**Subdirectory README content:**
- Specific purpose of this subdirectory (why was it created)
- How it differs from sibling directories
- Structure and organization within subdirectory

## Work Instruction Types

An actor is any entity that assumes a role: human, AI agent, or service.

All work instructions describe processes fulfilled by actors:

- **Principles** - immutable rules that govern execution
- **Roles** - responsibilities and boundaries for any actor
- **Tasks** - actions performed by one or more actors
- **Tools** - resources used to perform tasks

Write documentation that helps any actor understand and execute effectively.

### Principles

Principles describe organization-wide immutable rules that all actors must respect.

The purpose of a principles document (also called a constitution) is to define what must always be true across the organization. This is important because principles provide the foundation that roles, tasks, and tools build upon.

Principles differ from other work instruction types:
- **Principles** = organization-level truths (always true, regardless of actor or action)
- **Roles** = actor-level guardrails (boundaries for a specific actor type)
- **Tasks** = action-level prerequisites (what must be true before this action)

**Structure of a principles document:**

```markdown
# [Organization/Domain] Principles

## Core Principles

### I. [Principle Name]
[What must always be true]
[Why this principle exists]

### II. [Principle Name]
...

## Governance

[How principles are amended]

**Version**: X.Y | **Ratified**: YYYY-MM-DD
```

**Include organization-specific information:**
- Non-negotiable constraints (what must always be true)
- Quality thresholds (measurable standards that apply universally)
- Amendment process (how principles evolve over time)

### Roles

Roles describe the contract between an actor and the organization.

The role work instruction defines boundaries that dictate the extent an actor can augment, automate, or change tasks and tools.

**Include organization-specific information:**
- Authority boundaries and escalation thresholds
- Your vocabulary and terminology (not general definitions)
- Common request patterns and expected responses
- Scope limitations (what's outside this role)

### Tasks

Tasks describe what and how an actor performs an action.

Many task work instructions require the use of tools. You will be tempted to include tool instructions in your tasks. **Don't do it!** If you have a task that depends on a tool, reference the tool work instruction so that someone can find the dedicated instructions when needed.

**Best practice example:**
> Find open orders using the ERP => (reference to tool page)

In this example:
- State the destination using general breadcrumb navigation
- Do not include screenshots or pictures
- Do not explain how to find or navigate the ERP
- Simply describe the path and link to the tool work instructions

**Include organization-specific information:**
- Decision points where clarification is needed (your business rules)
- Edge case handling specific to your organization
- Prerequisites and assumptions to verify before acting
- Confidence thresholds (when to confirm vs. proceed)

### Tools

Tools describe the physical and digital resources, systems, and technologies used to execute tasks.

The biggest challenge with tool instructions is finding the minimum documentation needed to create success. Error on the side of writing less and test your work instructions. You can always write more later.

**Naming conventions for tool references:**

Be consistent with how you refer to tool objects:

- **Capitalize window/menu names, lowercase "window"**
  - Example: Sales Order window
  - Example: Payment Term window

- **Use quotes for specific items** when there is potential for confusion
  - Example: Payment Term window => "Net 10" record
  - Example: Status field => "Approved" option

- **Use breadcrumbs for multi-step navigation**
  - Example: ERP => Sales Order window => Line subtab => Process toolbar => Copy Lines process
  - Pattern: System => Window => Tab => Section => Action

**What to include in tool documents:**
- How to launch or access the tool
- Navigation patterns within the tool
- Key interface elements and their purpose
- Common operations and workflows
- Tool-specific configurations

**Include organization-specific information:**
- Your system configurations and customizations
- Common error states and what they mean in your context
- How to translate technical outputs to non-technical language

### Example: Training-Enriched Role Documentation

Here's how organization-specific training information enhances work instructions:

**Role Example - AP Clerk:**

```markdown
# AP Clerk Role

The purpose of this role is to process accounts payable invoices from receipt through payment.

**Authority Boundaries:**
- Approve invoices up to $5,000
- Invoices $5,000-$10,000 require supervisor approval
- Invoices >$10,000 require manager approval

**Organization Vocabulary:**
- "Held invoice" = invoice pending additional information
- "Process invoice" = match to PO, verify amounts, approve, schedule payment

**Common Requests:**
- "Where's invoice #123?" → Check ERP status, provide current state
- "Rush this payment" → Verify authority, escalate if >$5,000
```

This example shows organization-specific content (YOUR approval thresholds, YOUR terminology, YOUR escalation rules) rather than general concepts.

## Why Markdown

The purpose of this section is to explain why markdown is the preferred format for work instructions.

This is important because markdown works everywhere and ensures your words remain accessible and usable indefinitely.

**Mass utilization:**
- **Web** - Renders beautifully in browsers and documentation sites
- **Terminal** - Readable in command-line interfaces and text editors
- **Code** - Native format in development environments and version control
- **AI** - Easily processed by language models and automation tools
- **Plain text** - Future-proof, tool-independent, always accessible

**Key benefits:**
- Human-readable in raw form (no special tools required)
- Machine-readable for automation and AI processing
- Version control friendly (git tracks changes clearly)
- Platform independent (works on any operating system)
- Zero lock-in (never trapped in proprietary formats)

Avoid formats like Word documents or Google Docs that trap your content in specific tools. Markdown keeps your words free and universally accessible.

## Markdown Document Structure

The purpose of this section is to establish proper heading hierarchy in markdown documents.

This is important because correct structure ensures documents are scannable, navigable, and accessible.

**Document Structure:**
- `#` (H1) = Document title (one per page on the first line)
- `##` (H2) = Major sections
- `###` (H3) = Subsections
- This hierarchy makes documents scannable and navigable

As a general rule, include a 'Table of Contents' or TOC as the first `##` (H2). Here is a quick script to help visualize in list form the current TOC of any markdown document:

```
./toc.sh <file.md>
```

## Markdown Task Lists

Task lists are a common tool when creating work instructions. Humans understand them. AI understands them. Use them to articulate clear and concise steps, dependencies, and completion criteria for any process or workflow.

### Simple Task List Example

In Markdown, you create task lists by doing the following:

- [ ] start with a bullet '-' for unordered lists or a '1.'
- [ ] follow the bullet with brackets '[ ]'

The above is a bulleted (unordered) list. Here is how you create a numbered list where the numbers will auto-increment when viewed in a markdown format:

1. [ ] First item
1. [ ] Second item
1. [ ] Third item

> **📝 Note** - this example needs to be replaced with an existing reference to confirm with the above guidelines.

### Hierarchical Task List Example

There are times when a task list item needs a sub task.

Here is an example illustrating how to extract an invoice from email
- [ ] Check for PDF attachments
- [ ] Parse email body if no attachment
- [ ] Extract key fields
  - [ ] Invoice number
  - [ ] Amount
  - [ ] Due date

> **📝 Note** - this example needs to be replaced with an existing reference to confirm with the above guidelines.

## Document Naming Convention

Here are guidelines for naming work instruction files:

- Case and format:
  - Begin the file name with the most dominant word. 
  - Adjectives should go next.
  - The work instruction type (role, task, tool) should go last.
  - Example: 'invoice-ap-email-to-document-process-task.md'
  - This convention ensures like documents appear next to each other in an alphabetical list.
- use all lower case and '-' instead of spaces. This practice ensures quick and easy processing on all platforms.

## Directory Structure

Try to use a single directory with no sub-directories. Here is why:

- You can search for key turns using: `ls *some-term*` with no additional complexity or search through sub-directories.
- You can see all documents in one place.
- A directory hierarchy only has one dimension. There are times when a document belongs in two or more places.
- Use tags in your markdown to assign multiple organization strategies to a single file.
- Tags are easy to identify and reason about.

## Tags

There are times when you need to need to tag to the bottom of a work instruction as belonging to a group or concept. Use the tagging convention to 'tag' the document with a key term. Here is an example where you can tag a document as belonging to multiple roles.

```md
This is a sample work instruction with a bunch of details.

Tags: #role-ap-clerk #role-ap-manager
```
## Notes Warnings Tips References and Comments

Here is the guide for calling special boxes that draw attention to important information:

```md
> 📝 **Note** - Additional information
> ⚠️ **Warning** - Potential issues
> 💡 **Tip** - Best practices
> 🔗 **Reference** - Links to other instructions
> 💬 **Comment** - Discussion points or feedback
```

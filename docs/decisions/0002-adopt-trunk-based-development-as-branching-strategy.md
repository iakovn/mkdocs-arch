# Adopt Trunk-Based Development as Branching Strategy

* Status: Proposed
* Deciders: iakovn
* Date: 2025-10-22

## Context and Problem Statement

The current branching strategy involves long-lived feature branches and/or GitFlow-like workflows. This leads to delayed integration, increased merge conflicts, variability in code quality, and difficulty in maintaining continuous delivery practices.  
We need a branching strategy that supports rapid integration, enables continuous delivery, reduces overhead in merge and release processes, and fosters team collaboration.

**How should we manage our branching and integration workflow to optimize for speed, stability, and continuous delivery?**

## Decision Drivers

* Desire to reduce integration pain and merge conflicts
* Align development process with continuous delivery and DevOps practices
* Improve visibility of current code state
* Increase frequency of deployable increments
* Reduce process overhead and branch management complexity

## Considered Options

* GitFlow with long-lived branches
* Feature Branches with Pull Requests (short-lived)
* Trunk-Based Development (TBD)
* Fork-based development model
* Short-Lived Feature Branches
* **Trunk-Based Development (Chosen)**
* Fork-Based Model

## Decision Outcome

Chosen option: "Trunk-Based Development", because :

- Encourages continuous integration and small, incremental commits
- Supports CI/CD automation and faster releases
- Reduces merge complexity through short-lived branches or direct commits
- Enhances team collaboration by maintaining a single source of truth
- Aligns with modern DevOps and platform team best practices

### Positive Consequences

* Faster feedback cycles
* Reduced merge conflicts and integration problems
* Easier to maintain release readiness
* Encourages use of feature toggles and incremental delivery

### Negative Consequences

* Requires discipline and cultural shift in the team
* Feature toggles or “dark releases” may increase code complexity
* Some developers may resist abandoning long-lived feature branches

## Pros and Cons of the Options

### GitFlow with long-lived branches

**Pros:** Clear separation of release and development; suitable for long release cycles  
**Cons:** Heavy branching overhead, slow feedback, incompatible with continuous delivery

### Short-Lived Feature Branches

**Pros:** Familiar workflow; allows code review before merging  
**Cons:** Still prone to integration delays if branches live too long

### **Trunk-Based Development (Chosen)**

**Pros:** Fast integration; optimized for CI/CD; reduces overhead; supports continuous delivery  
**Cons:** Requires strong engineering practices (e.g., feature toggles, automated tests)

### Fork-Based Model

**Pros:** Good for open-source and distributed contributors  
**Cons:** High overhead and not optimized for internal team velocity

## Links

* https://trunkbaseddevelopment.com/
* [feature lifecycle](../tbd-feature-lifecycle.md)
* Internal CI/CD pipeline documentation (to be updated)

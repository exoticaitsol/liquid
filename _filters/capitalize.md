---
title: capitalize
description: Liquid filter that capitalizes the first character of a string.
---

Makes the first character of a string capitalized.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "title" | capitalize }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "title" | capitalize }}
```

`capitalize` only capitalizes the first character of a string, so later words are not affected:

 <p class="code-label">Input</p>
```liquid
{% raw %}
{{ "my great title" | capitalize }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "my great title" | capitalize }}
```
---
title: FAQ
description: Common questions and answers for them.
---
## My tests are failing when I'm running them with Test Runner, but when I run them normally, everything is green.

This is because your tests are not isolated and they are interfering each other. Please use `validate` command to see how you can resolve it.

Additionally, make sure that your singleton classes are being reset before each group.
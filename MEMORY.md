# MEMORY.md — session context checkpoint

## Current branch
`main` (up to date with `origin/main`)

## Commits applied (caiohamamura, 2026-05-19)
| Commit | What |
|--------|------|
| `ddd8ab4` | Fix `-Wstrict-prototypes` warnings in `utils_c.c` (`rams_c_close`, `sched_getcpu`, `findmycpu_` → add `void`) |
| `e455d50` | Fix MPI smoke test: `I_MPI_OFI_PROVIDER` from `shm` (invalid) to `tcp` (valid OFI provider) |
| `f3a0165` | Fix ASAN link failure on macOS m1-san + MPI fabrics cross-platform |

## What was fixed

### 1. `-Wstrict-prototypes` warnings (Intel Linux CI)
- `src/ED2/ED/src/utils/utils_c.c:149` — `rams_c_close()` → `rams_c_close(void)`
- `src/ED2/ED/src/utils/utils_c.c:552` — `sched_getcpu()` → `sched_getcpu(void)`
- `src/ED2/ED/src/utils/utils_c.c:553` — `findmycpu_()` → `findmycpu_(void)`

### 2. Intel MPI OFI init failure (Windows + Linux CI)
Intel MPI defaults to `I_MPI_FABRICS=shm:ofi` which requires a working OFI provider.
On CI runners without InfiniBand/OPA fabrics, OFI init fails with:
```
MPIDI_OFI_mpi_init_hook: Unknown error class / Other MPI error
```
- `I_MPI_FABRICS=shm` now set in smoke test on ALL platforms (was Windows-only).
  Disables OFI entirely for single-node 2-process smoke test.
- `I_MPI_OFI_PROVIDER=tcp` kept Windows-only as safety net.
- File: `tools/smoke_test_binary_package.R:55-62`

### 3. ASAN/UBSAN link failure (macOS arm64 m1-san)
R's CFLAGS on CRAN ASAN check machines include `-fsanitize=address,undefined`.
C source (`utils_c.c`) compiled with sanitizer → ASAN runtime calls in object file.
gfortran linker does not pass `-fsanitize` → unresolved `__asan_*` / `__ubsan_*` symbols.
- Fix: strip `-fsanitize=*` from CFLAGS in `configure.ac:236`
- File: `configure.ac` (regenerated `configure` committed too)

### 4. Empty `inst/` directory warning
- `cleanup`: added `rm -rf inst` after `rm -rf inst/bin`
- `.gitignore`: `inst/bin` → `inst/`

## What remains / should be verified
- Push to CI and confirm all lanes pass (Intel Linux MPI, Windows MPI, macOS m1-san)
- The ASAN fix was regenerated with autoconf 2.73 — ensure `configure.ucrt` was also updated
  (run `make preprocess` on a system with autotools)
- No `inst/` directory should remain in the source tree

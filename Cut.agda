
open import Prelude hiding (⊥)
open import Foc

module Cut where

fromctx : ∀{A B Γ} (Γ' : Ctx) → B ∈ (Γ' ++ A :: Γ) → (A ≡ B) + (B ∈ (Γ' ++ Γ))
fromctx [] Z = Inl Refl
fromctx [] (S x) = Inr x
fromctx (A :: Γ') Z = Inr Z
fromctx (A :: Γ') (S x) with fromctx Γ' x
... | Inl Refl = Inl Refl
... | Inr x' = Inr (S x')

subst⁺ : ∀{Γ A Ω C}
  → Value [] Γ A
  → Term [] Γ (A :: Ω) (Reg C)
  → Term [] Γ Ω (Reg C)

subst⁻ : ∀{Γ A C} 
  → (Reg C) stable⁻
  → Term [] Γ [] (Reg A)
  → Spine [] Γ A (Reg C)
  → Term [] Γ [] (Reg C)

rsubstV : ∀{Γ A C} (Γ' : Ctx)
  → Term [] Γ [] (Reg A)
  → Value [] (Γ' ++ (↓ A) :: Γ) C
  → Value [] (Γ' ++ Γ) C

rsubstN : ∀{Γ A Ω C} (Γ' : Ctx)
  → Term [] Γ [] (Reg A)
  → Term [] (Γ' ++ (↓ A) :: Γ) Ω (Reg C)
  → Term [] (Γ' ++ Γ) Ω (Reg C)

rsubstSp : ∀{Γ A B C} (Γ' : Ctx)
  → Term [] Γ [] (Reg A)
  → Spine [] (Γ' ++ (↓ A) :: Γ) B (Reg C)
  → Spine [] (Γ' ++ Γ) B (Reg C)

lsubstN : ∀{Γ C Ω A} (Γ' : Ctx)
  → (Reg C) stable⁻
  → Term [] (Γ' ++ Γ) Ω (Reg (↑ A))
  → Term [] Γ [ A ] (Reg C)
  → Term [] (Γ' ++ Γ) Ω (Reg C)

lsubstSp : ∀{Γ C B A} (Γ' : Ctx)
  → (Reg C) stable⁻
  → Spine [] (Γ' ++ Γ) B (Reg (↑ A))
  → Term [] Γ [ A ] (Reg C)
  → Spine [] (Γ' ++ Γ) B (Reg C)

subst⁺ (hyp⁺ ()) N
subst⁺ (pR x) (L pf⁺ N) = wk (LIST.SET.sub-cntr x) N
subst⁺ (↓R N) (L pf⁺ N') = rsubstN [] N N'
subst⁺ (∨R₁ V) (∨L N₁ N₂) = subst⁺ V N₁
subst⁺ (∨R₁ V) (L () N)
subst⁺ (∨R₂ V) (∨L N₁ N₂) = subst⁺ V N₂
subst⁺ (∨R₂ V) (L () N)
subst⁺ ⊤⁺R (⊤⁺L N) = N
subst⁺ ⊤⁺R (L () N)
subst⁺ (∧⁺R V₁ V₂) (∧⁺L N) = subst⁺ V₂ (subst⁺ V₁ N)
subst⁺ (∧⁺R V₁ V₂) (L () N) 

subst⁻ pf (↓L pf⁻ x Sp) pL = ↓L pf⁻ x Sp
subst⁻ pf (↓L pf⁻ x Sp) (↑L N) = ↓L pf x (lsubstSp [] pf Sp N)
subst⁻ pf (↓L () x Sp) (⊃L V Sp')
subst⁻ pf (↓L () x Sp) (∧⁻L₁ Sp')
subst⁻ pf (↓L () x Sp) (∧⁻L₂ Sp')
subst⁻ pf (↑R V) (↑L N) = subst⁺ V N
subst⁻ pf (⊃R N) (⊃L V Sp) = subst⁻ pf (subst⁺ V N) Sp
subst⁻ pf ⊤⁻R ()
subst⁻ pf (∧⁻R N₁ N₂) (∧⁻L₁ Sp) = subst⁻ pf N₁ Sp
subst⁻ pf (∧⁻R N₁ N₂) (∧⁻L₂ Sp) = subst⁻ pf N₂ Sp

rsubstV Γ' N (hyp⁺ ())
rsubstV Γ' N (pR x) with fromctx Γ' x
... | Inl ()
... | Inr x' = pR x'
rsubstV Γ' N (↓R N') = ↓R (rsubstN Γ' N N')
rsubstV Γ' N (∨R₁ V) = ∨R₁ (rsubstV Γ' N V)
rsubstV Γ' N (∨R₂ V) = ∨R₂ (rsubstV Γ' N V)
rsubstV Γ' N ⊤⁺R = ⊤⁺R
rsubstV Γ' N (∧⁺R V₁ V₂) = ∧⁺R (rsubstV Γ' N V₁) (rsubstV Γ' N V₂)

rsubstN Γ' N (L pf⁺ N') = L pf⁺ (rsubstN (_ :: Γ') N N')
rsubstN Γ' N (↓L pf⁻ x Sp) with fromctx Γ' x
... | Inl Refl = 
  subst⁻ pf⁻ (wk (LIST.SET.sub-appendl _ Γ') N) (rsubstSp Γ' N Sp)
... | Inr x' = ↓L pf⁻ x' (rsubstSp Γ' N Sp)
rsubstN Γ' N ⊥L = ⊥L
rsubstN Γ' N (∨L N₁ N₂) = ∨L (rsubstN Γ' N N₁) (rsubstN Γ' N N₂)
rsubstN Γ' N (⊤⁺L N') = ⊤⁺L (rsubstN Γ' N N')
rsubstN Γ' N (∧⁺L N') = ∧⁺L (rsubstN Γ' N N')
rsubstN Γ' N (↑R V) = ↑R (rsubstV Γ' N V)
rsubstN Γ' N (⊃R N') = ⊃R (rsubstN Γ' N N')
rsubstN Γ' N ⊤⁻R = ⊤⁻R
rsubstN Γ' N (∧⁻R N₁ N₂) = ∧⁻R (rsubstN Γ' N N₁) (rsubstN Γ' N N₂)

rsubstSp Γ' N pL = pL
rsubstSp Γ' N (↑L N') = ↑L (rsubstN Γ' N N')
rsubstSp Γ' N (⊃L V Sp) = ⊃L (rsubstV Γ' N V) (rsubstSp Γ' N Sp)
rsubstSp Γ' N (∧⁻L₁ Sp) = ∧⁻L₁ (rsubstSp Γ' N Sp)
rsubstSp Γ' N (∧⁻L₂ Sp) = ∧⁻L₂ (rsubstSp Γ' N Sp)

lsubstN Γ' pf (L pf⁺ N') N = L pf⁺ (lsubstN (_ :: Γ') pf N' N)
lsubstN Γ' pf (↓L pf⁻ x Sp) N = ↓L pf x (lsubstSp Γ' pf Sp N)
lsubstN Γ' pf ⊥L N = ⊥L
lsubstN Γ' pf (∨L N₁ N₂) N = ∨L (lsubstN Γ' pf N₁ N) (lsubstN Γ' pf N₂ N)
lsubstN Γ' pf (⊤⁺L N') N = ⊤⁺L (lsubstN Γ' pf N' N)
lsubstN Γ' pf (∧⁺L N') N = ∧⁺L (lsubstN Γ' pf N' N)
lsubstN Γ' pf (↑R V) N = subst⁺ V (wk (LIST.SET.sub-appendl _ Γ') N)

lsubstSp Γ' pf (↑L N') N = ↑L (lsubstN Γ' pf N' N)
lsubstSp Γ' pf (⊃L V Sp) N = ⊃L V (lsubstSp Γ' pf Sp N)
lsubstSp Γ' pf (∧⁻L₁ Sp) N = ∧⁻L₁ (lsubstSp Γ' pf Sp N)
lsubstSp Γ' pf (∧⁻L₂ Sp) N = ∧⁻L₂ (lsubstSp Γ' pf Sp N)

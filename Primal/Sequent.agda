-- Sequent Calculus for Primal Infon Logic
-- Robert J. Simmons

open import Prelude
open import Infon.Core
open import Primal.SequentCore
open import Primal.SequentAxiom

module Primal.Sequent where

module SEQUENT (Prin : Set; _≡?_ : (p q : Prin) → Decidable (p ≡ q)) where

   open CORE Prin _≡?_
   open SEQUENT-CORE Prin _≡?_ public
   open SEQUENT-CUT Prin _≡?_ public

   cut' : ∀{Γ A C} → Γ ⇒ A → (A true) :: Γ ⇒ C → Γ ⇒ C
   cut' D E = cut (→m D) (→m E)

   cut□' : ∀{Γ A C p} → Γ ○ p ⇒ A → (p said A) :: Γ ⇒ C → Γ ⇒ C
   cut□' D E = cut□ D (→m E)

   cut■' : ∀{Γ A C p} → Γ ● p ⇒ A → (p implied A) :: Γ ⇒ C → Γ ⇒ C
   cut■' D E = cut■ D (→m E)

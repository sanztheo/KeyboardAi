import UIKit

extension UIInputViewController {

    struct BestEffortResult {
        let text: String
        let totalAccessibleLength: Int
        let reachedLeftEdge: Bool
        let reachedRightEdge: Bool
    }

    @discardableResult
    func bestEffortReadAll(step: Int = 128, maxHops: Int = 20000) -> BestEffortResult {
        let proxy = textDocumentProxy

        // 1) Aller au bord gauche le plus accessible
        var movedLeftTotal = 0
        var leftHops = 0
        while leftHops < maxHops, let b = proxy.documentContextBeforeInput, !b.isEmpty {
            let jump = b.count
            if Thread.isMainThread {
                proxy.adjustTextPosition(byCharacterOffset: -jump)
            } else {
                DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: -jump) }
            }
            movedLeftTotal += jump
            leftHops += 1
        }
        let reachedLeft = (proxy.documentContextBeforeInput?.isEmpty ?? true)

        // 2) Balayer vers la droite en accumulant tous les chunks exposés
        var assembled = ""
        var movedRightTotal = 0
        var rightHops = 0
        while rightHops < maxHops, let a = proxy.documentContextAfterInput, !a.isEmpty {
            assembled += a
            if Thread.isMainThread {
                proxy.adjustTextPosition(byCharacterOffset: a.count)
            } else {
                DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: a.count) }
            }
            movedRightTotal += a.count
            #if DEBUG
            if rightHops % 50 == 0 {
                let bCount = proxy.documentContextBeforeInput?.count ?? 0
                let aCount = proxy.documentContextAfterInput?.count ?? 0
                print("[KeyboardAI] sweep hop=\(rightHops) before=\(bCount) after=\(aCount)")
            }
            #endif
            rightHops += 1
        }
        let reachedRight = (proxy.documentContextAfterInput?.isEmpty ?? true)
        let totalAccessible = movedRightTotal
        #if DEBUG
        print("[KeyboardAI] SelectAll best-effort: reachedLeft=\(reachedLeft) reachedRight=\(reachedRight) totalAccessible=\(totalAccessible)")
        #endif

        // 3) Revenir exactement à la position initiale
        let restoreOffset = movedLeftTotal - movedRightTotal
        if restoreOffset != 0 {
            if Thread.isMainThread {
                proxy.adjustTextPosition(byCharacterOffset: restoreOffset)
            } else {
                DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: restoreOffset) }
            }
        }

        return BestEffortResult(
            text: assembled,
            totalAccessibleLength: totalAccessible,
            reachedLeftEdge: reachedLeft,
            reachedRightEdge: reachedRight
        )
    }

    /// Variante avec "probes" pour forcer le défilement de la fenêtre de contexte
    /// et capturer la totalité du texte accessible, même lorsque `documentContextAfterInput`
    /// devient vide. Utilise une séquence de pas croissants pour révéler la suite.
    @discardableResult
    func bestEffortReadAllWithProbes(step: Int = 128,
                                     maxHops: Int = 20000,
                                     probeSeq: [Int] = [1, 8, 32, 128]) -> BestEffortResult {
        let proxy = textDocumentProxy

        // 1) Aller au bord gauche
        var movedLeftTotal = 0
        var leftHops = 0
        while leftHops < maxHops, let b = proxy.documentContextBeforeInput, !b.isEmpty {
            let jump = b.count
            if Thread.isMainThread { proxy.adjustTextPosition(byCharacterOffset: -jump) }
            else { DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: -jump) } }
            movedLeftTotal += jump
            leftHops += 1
        }
        let reachedLeft = (proxy.documentContextBeforeInput?.isEmpty ?? true)

        // 2) Balayer droite + probes
        var assembled = ""
        var movedRightTotal = 0
        var rightHops = 0

        while rightHops < maxHops {
            // 2.a Chunks exposés
            while rightHops < maxHops, let a = proxy.documentContextAfterInput, !a.isEmpty {
                assembled += a
                if Thread.isMainThread { proxy.adjustTextPosition(byCharacterOffset: a.count) }
                else { DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: a.count) } }
                movedRightTotal += a.count
                rightHops += 1
                #if DEBUG
                if rightHops % 50 == 0 {
                    let bCount = proxy.documentContextBeforeInput?.count ?? 0
                    let aCount = proxy.documentContextAfterInput?.count ?? 0
                    print("[KeyboardAI] probe-sweep hop=\(rightHops) before=\(bCount) after=\(aCount)")
                }
                #endif
            }

            if rightHops >= maxHops { break }

            // 2.b Probes pour révéler plus loin
            var progressed = false
            for p in probeSeq {
                let b0 = proxy.documentContextBeforeInput ?? ""
                let a0 = proxy.documentContextAfterInput ?? ""
                let b0c = b0.count
                let a0c = a0.count

                if Thread.isMainThread { proxy.adjustTextPosition(byCharacterOffset: p) }
                else { DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: p) } }

                // Donne une chance à l'hôte de rafraîchir les contextes
                RunLoop.current.run(until: Date().addingTimeInterval(0.0))

                let b1 = proxy.documentContextBeforeInput ?? ""
                let a1 = proxy.documentContextAfterInput ?? ""
                let b1c = b1.count
                let a1c = a1.count

                // Mouvement effectif = au plus le pas demandé (p). Ne pas compter le glissement de fenêtre.
                let rawDelta = max(0, b1c - b0c)
                let progress = min(p, rawDelta)
                let moved = (progress > 0) || (a1c < a0c) || (b0 != b1) || (a0 != a1)
                if moved {
                    // Ajouter uniquement les caractères effectivement parcourus
                    var gained = 0
                    if progress > 0 {
                        let newFrag = String(b1.suffix(progress))
                        assembled += newFrag
                        gained = progress
                    } else if a1c < a0c && a0c > 0 { // fallback: prendre dans l'ancien after
                        let take = min(p, a0c)
                        let newFrag = String(a0.prefix(take))
                        assembled += newFrag
                        gained = take
                    }
                    movedRightTotal += gained
                    progressed = true
                    rightHops += 1
                    break
                }
                // Si aucune progression, on ne revert pas (pas de mouvement effectif)
            }

            if !progressed { break }
        }

        let reachedRight = (proxy.documentContextAfterInput?.isEmpty ?? true) || (rightHops >= maxHops)
        let totalAccessible = movedRightTotal
        #if DEBUG
        print("[KeyboardAI] SelectAll probe: reachedLeft=\(reachedLeft) reachedRight=\(reachedRight) totalAccessible=\(totalAccessible)")
        #endif

        // 3) Restaurer position initiale
        let restore = movedLeftTotal - movedRightTotal
        if restore != 0 {
            if Thread.isMainThread { proxy.adjustTextPosition(byCharacterOffset: restore) }
            else { DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: restore) } }
        }

        return BestEffortResult(
            text: assembled,
            totalAccessibleLength: totalAccessible,
            reachedLeftEdge: reachedLeft,
            reachedRightEdge: reachedRight
        )
    }
}

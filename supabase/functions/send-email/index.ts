// Supabase Edge Function: send-email
// Handles SMTP email sending server-side.
// Compatible con Deno v2 usando denomailer@1.6.0
//
// Environment variables (set via Supabase dashboard):
//   SMTP_HOST, SMTP_USER, SMTP_PASS, FROM_EMAIL, ADMIN_EMAIL
//
// Receives: { type, to, data }
// Supported types:
//   welcome | order-confirmation | admin-order-notification |
//   order-status | cancellation-invoice | password-reset |
//   contact-form | problem-report | newsletter

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
};

async function sendEmail(to: string, subject: string, html: string): Promise<boolean> {
    const smtpHost = Deno.env.get("SMTP_HOST") || "";
    const smtpUser = Deno.env.get("SMTP_USER") || "";
    const smtpPass = Deno.env.get("SMTP_PASS") || "";
    const fromEmail = Deno.env.get("FROM_EMAIL") || smtpUser;

    if (!smtpUser || !smtpPass || !smtpHost) {
        console.error("❌ SMTP no configurado (SMTP_HOST, SMTP_USER o SMTP_PASS vacíos)");
        return false;
    }

    const client = new SMTPClient({
        connection: {
            hostname: smtpHost,
            port: 465,
            tls: true,
            auth: {
                username: smtpUser,
                password: smtpPass,
            },
        },
    });

    try {
        await client.send({
            from: `KicksPremium <${fromEmail}>`,
            to: to,
            subject: subject,
            content: "Este correo requiere un cliente compatible con HTML.",
            html: html,
        });

        await client.close();
        console.log(`✅ Email enviado correctamente a ${to}`);
        return true;
    } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error(`❌ Error enviando email a ${to}: ${msg}`);
        try { await client.close(); } catch (_) { /* ignorar */ }
        return false;
    }
}

// ─── Email Templates ────────────────────────────────────────────────────────

function getWelcomeTemplate(userName: string): { subject: string; html: string } {
    return {
        subject: "¡Bienvenido a KicksPremium! 👟",
        html: `<!DOCTYPE html><html><head><meta charset="UTF-8"><style>body{font-family:Arial,sans-serif;line-height:1.6;color:#333}.container{max-width:600px;margin:0 auto;padding:20px}.header{background:#1a1a1a;color:#fff;padding:20px;text-align:center;border-radius:5px}.content{padding:20px;background:#f9f9f9;border-radius:5px}.footer{text-align:center;padding:20px;color:#666;font-size:12px}.button{display:inline-block;padding:10px 20px;background:#FFD700;color:#000;text-decoration:none;border-radius:5px;margin:10px 0}</style></head><body><div class="container"><div class="header"><h1>👟 ¡Bienvenido a KicksPremium!</h1></div><div class="content"><p>Hola <strong>${userName}</strong>,</p><p>¡Gracias por registrarte en KicksPremium!</p><p>En KicksPremium encontrarás:</p><ul><li>✅ Zapatillas auténticas de las mejores marcas</li><li>✅ Precios competitivos</li><li>✅ Envíos rápidos y seguros</li><li>✅ Atención al cliente 24/7</li></ul><a href="https://kickspremium.com" class="button">Explorar Zapatillas</a></div><div class="footer"><p>© 2026 KicksPremium. Todos los derechos reservados.</p></div></div></body></html>`,
    };
}

function getOrderConfirmationTemplate(orderId: string, totalAmount: number, items: Array<Record<string, unknown>>): { subject: string; html: string } {
    const baseAmount = totalAmount / 1.21;
    const ivaAmount = totalAmount - baseAmount;

    const itemsHtml = items.map((item: Record<string, unknown>) => {
        const price = typeof item.price === "number" ? item.price : parseFloat(String(item.price)) || 0;
        const qty = (item.quantity as number) || 1;
        const lineTotal = price * qty;
        const imageUrl = (item.image as string) || "";
        const name = (item.name as string) || "";
        const brand = (item.brand as string) || "";
        const size = (item.size as string) || "";
        const imageTag = imageUrl
            ? `<img src="${imageUrl}" width="60" height="60" alt="${name}" style="border-radius:8px;object-fit:cover;">`
            : `<div style="width:60px;height:60px;background:#333;border-radius:8px;"></div>`;

        return `<tr><td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;">${imageTag}</td><td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;color:#fff;"><strong>${name}</strong><br><span style="color:#999;font-size:12px;">${brand} · Talla ${size}</span></td><td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;text-align:center;color:#ccc;">${qty}</td><td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;text-align:right;color:#FFD700;font-weight:bold;">€${price.toFixed(2)}</td><td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;text-align:right;color:#fff;">€${lineTotal.toFixed(2)}</td></tr>`;
    }).join("");

    return {
        subject: `Confirmación de tu pedido #${orderId} - KicksPremium 📦`,
        html: `<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body style="margin:0;padding:0;background:#0a0a0a;font-family:'Helvetica Neue',Arial,sans-serif;"><div style="max-width:600px;margin:0 auto;background:#121212;"><div style="background:linear-gradient(135deg,#1a1a1a 0%,#2a2a2a 100%);padding:30px;text-align:center;border-bottom:3px solid #FFD700;"><h1 style="margin:0;color:#FFD700;font-size:24px;letter-spacing:2px;">KICKSPREMIUM</h1><p style="margin:8px 0 0;color:#ccc;font-size:13px;">FACTURA DE COMPRA</p></div><div style="text-align:center;padding:20px 0 10px;"><span style="background:#FFD700;color:#000;padding:6px 18px;border-radius:20px;font-size:13px;font-weight:bold;">Pedido #${orderId}</span></div><div style="padding:20px 24px;"><p style="color:#ccc;font-size:14px;">¡Tu pedido ha sido confirmado con éxito!</p><table style="width:100%;border-collapse:collapse;margin:16px 0;"><thead><tr style="background:#1e1e1e;"><th style="padding:10px 8px;text-align:left;color:#999;font-size:11px;text-transform:uppercase;width:60px;"></th><th style="padding:10px 8px;text-align:left;color:#999;font-size:11px;text-transform:uppercase;">Producto</th><th style="padding:10px 8px;text-align:center;color:#999;font-size:11px;text-transform:uppercase;">Ud.</th><th style="padding:10px 8px;text-align:right;color:#999;font-size:11px;text-transform:uppercase;">Precio</th><th style="padding:10px 8px;text-align:right;color:#999;font-size:11px;text-transform:uppercase;">Total</th></tr></thead><tbody>${itemsHtml}</tbody></table><div style="background:#1a1a1a;border-radius:10px;padding:16px;margin-top:16px;"><table style="width:100%;border-collapse:collapse;"><tr><td style="padding:6px 0;color:#999;font-size:13px;">Subtotal (sin IVA)</td><td style="padding:6px 0;text-align:right;color:#ccc;font-size:13px;">€${baseAmount.toFixed(2)}</td></tr><tr><td style="padding:6px 0;color:#999;font-size:13px;">IVA (21%)</td><td style="padding:6px 0;text-align:right;color:#ccc;font-size:13px;">€${ivaAmount.toFixed(2)}</td></tr><tr><td style="padding:6px 0;color:#999;font-size:13px;">Envío</td><td style="padding:6px 0;text-align:right;color:#4CAF50;font-size:13px;">GRATIS</td></tr><tr style="border-top:2px solid #333;"><td style="padding:12px 0 0;color:#fff;font-size:18px;font-weight:bold;">TOTAL</td><td style="padding:12px 0 0;text-align:right;color:#FFD700;font-size:22px;font-weight:bold;">€${totalAmount.toFixed(2)}</td></tr></table></div></div><div style="text-align:center;padding:20px;border-top:1px solid #2a2a2a;color:#666;font-size:11px;"><p style="margin:0;">¿Dudas? Escríbenos a <a href="mailto:support@kickspremium.com" style="color:#FFD700;">support@kickspremium.com</a></p><p style="margin:8px 0 0;">© 2026 KicksPremium. Todos los derechos reservados.</p></div></div></body></html>`,
    };
}

function getAdminOrderNotificationTemplate(orderId: string, customerEmail: string, totalAmount: number, items: Array<Record<string, unknown>>): { subject: string; html: string } {
    const itemsHtml = items.map((item: Record<string, unknown>) => {
        const name = (item.name as string) || "";
        const brand = (item.brand as string) || "";
        const size = (item.size as string) || "";
        const qty = (item.quantity as number) || 1;
        const price = typeof item.price === "number" ? item.price : parseFloat(String(item.price)) || 0;
        return `<tr><td style="padding:8px;border-bottom:1px solid #333;color:#ccc;">${name}</td><td style="padding:8px;border-bottom:1px solid #333;color:#999;">${brand}</td><td style="padding:8px;border-bottom:1px solid #333;color:#999;text-align:center;">${size}</td><td style="padding:8px;border-bottom:1px solid #333;color:#ccc;text-align:center;">${qty}</td><td style="padding:8px;border-bottom:1px solid #333;color:#FFD700;text-align:right;">€${price.toFixed(2)}</td></tr>`;
    }).join("");

    return {
        subject: `🔔 [NUEVO PEDIDO] #${orderId} - KicksPremium`,
        html: `<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;background:#0a0a0a;font-family:Arial,sans-serif;"><div style="max-width:600px;margin:0 auto;background:#121212;"><div style="background:#1a1a1a;padding:20px;text-align:center;border-bottom:3px solid #FF3131;"><h1 style="margin:0;color:#FF3131;font-size:20px;">🔔 NUEVO PEDIDO RECIBIDO</h1></div><div style="padding:20px 24px;"><div style="background:#1e1e1e;border-radius:10px;padding:16px;margin-bottom:16px;"><p style="margin:0;color:#999;font-size:12px;">PEDIDO</p><p style="margin:4px 0 0;color:#FFD700;font-size:20px;font-weight:bold;">#${orderId}</p></div><table style="width:100%;border-collapse:collapse;margin-bottom:16px;"><tr><td style="padding:8px 0;color:#999;">Cliente:</td><td style="padding:8px 0;color:#fff;text-align:right;">${customerEmail}</td></tr><tr><td style="padding:8px 0;color:#999;">Total:</td><td style="padding:8px 0;color:#FFD700;text-align:right;font-weight:bold;font-size:18px;">€${totalAmount.toFixed ? totalAmount.toFixed(2) : totalAmount}</td></tr></table><table style="width:100%;border-collapse:collapse;"><thead><tr style="background:#1e1e1e;"><th style="padding:8px;text-align:left;color:#999;font-size:11px;">Producto</th><th style="padding:8px;text-align:left;color:#999;font-size:11px;">Marca</th><th style="padding:8px;text-align:center;color:#999;font-size:11px;">Talla</th><th style="padding:8px;text-align:center;color:#999;font-size:11px;">Ud.</th><th style="padding:8px;text-align:right;color:#999;font-size:11px;">Precio</th></tr></thead><tbody>${itemsHtml}</tbody></table></div><div style="text-align:center;padding:16px;border-top:1px solid #333;"><a href="https://supabase.com/dashboard" style="background:#FF3131;color:#fff;padding:10px 24px;border-radius:8px;text-decoration:none;font-weight:bold;">Gestionar Pedido</a></div></div></body></html>`,
    };
}

function getCancellationInvoiceTemplate(orderId: string, amount: number, items: Array<Record<string, unknown>>): { subject: string; html: string } {
    const itemsHtml = items.map((item: Record<string, unknown>) => {
        const name = (item.name as string) || "";
        const qty = (item.quantity as number) || 1;
        const price = typeof item.price === "number" ? item.price : parseFloat(String(item.price)) || 0;
        return `<tr><td style="padding:8px;border-bottom:1px solid #333;color:#ccc;">${name}</td><td style="padding:8px;border-bottom:1px solid #333;color:#ccc;text-align:center;">${qty}</td><td style="padding:8px;border-bottom:1px solid #333;color:#ccc;text-align:right;">€${price.toFixed(2)}</td></tr>`;
    }).join("");

    return {
        subject: `Factura de abono - Pedido #${orderId} - KicksPremium`,
        html: `<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;background:#0a0a0a;font-family:Arial,sans-serif;"><div style="max-width:600px;margin:0 auto;background:#121212;"><div style="background:linear-gradient(135deg,#1a1a1a 0%,#2a2a2a 100%);padding:30px;text-align:center;border-bottom:3px solid #FF3131;"><h1 style="margin:0;color:#FFD700;font-size:24px;letter-spacing:2px;">KICKSPREMIUM</h1><p style="margin:8px 0 0;color:#ccc;font-size:13px;">FACTURA DE ABONO / REEMBOLSO</p></div><div style="text-align:center;padding:20px 0 10px;"><span style="background:#FF3131;color:#fff;padding:6px 18px;border-radius:20px;font-size:13px;font-weight:bold;">Pedido #${orderId}</span></div><div style="padding:20px 24px;"><p style="color:#ccc;font-size:14px;">Se ha procesado el reembolso de tu pedido.</p><table style="width:100%;border-collapse:collapse;margin:16px 0;"><thead><tr style="background:#1e1e1e;"><th style="padding:8px;text-align:left;color:#999;font-size:11px;">Producto</th><th style="padding:8px;text-align:center;color:#999;font-size:11px;">Ud.</th><th style="padding:8px;text-align:right;color:#999;font-size:11px;">Precio</th></tr></thead><tbody>${itemsHtml}</tbody></table><div style="background:#1a1a1a;border-radius:10px;padding:16px;margin-top:16px;"><table style="width:100%;border-collapse:collapse;"><tr style="border-top:2px solid #333;"><td style="padding:12px 0;color:#fff;font-size:18px;font-weight:bold;">REEMBOLSO TOTAL</td><td style="padding:12px 0;text-align:right;color:#4CAF50;font-size:22px;font-weight:bold;">€${amount.toFixed ? amount.toFixed(2) : amount}</td></tr></table></div><p style="color:#999;font-size:12px;margin-top:16px;">El reembolso se reflejará en tu cuenta en 5-10 días hábiles.</p></div><div style="text-align:center;padding:20px;border-top:1px solid #2a2a2a;color:#666;font-size:11px;"><p style="margin:0;">© 2026 KicksPremium. Todos los derechos reservados.</p></div></div></body></html>`,
    };
}

// ─── Main Handler ────────────────────────────────────────────────────────────

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const body = await req.json();
        const { type, to, data } = body;

        let subject = "";
        let html = "";
        let targetEmail = to;

        switch (type) {
            // ── Bienvenida ──
            case "welcome": {
                const t = getWelcomeTemplate(data.userName);
                subject = t.subject;
                html = t.html;
                break;
            }

            // ── Confirmación de pedido ──
            case "order-confirmation": {
                const t = getOrderConfirmationTemplate(data.orderId, data.totalAmount, data.items || []);
                subject = t.subject;
                html = t.html;
                break;
            }

            // ── Notificación al admin ──
            case "admin-order-notification": {
                const adminEmail = Deno.env.get("ADMIN_EMAIL") || to;
                const t = getAdminOrderNotificationTemplate(
                    data.orderId,
                    data.customerEmail,
                    data.totalAmount,
                    data.items || []
                );
                subject = t.subject;
                html = t.html;
                const success = await sendEmail(adminEmail, subject, html);
                return new Response(
                    JSON.stringify({ success }),
                    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // ── Actualización de estado ──
            case "order-status": {
                subject = `Tu pedido #${data.orderId} - ${data.status} - KicksPremium 📮`;
                html = `<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;background:#0a0a0a;font-family:Arial,sans-serif;"><div style="max-width:600px;margin:0 auto;background:#121212;"><div style="background:linear-gradient(135deg,#1a1a1a 0%,#2a2a2a 100%);padding:30px;text-align:center;border-bottom:3px solid #FFD700;"><h1 style="margin:0;color:#FFD700;font-size:24px;letter-spacing:2px;">KICKSPREMIUM</h1><p style="margin:8px 0 0;color:#ccc;font-size:13px;">ACTUALIZACIÓN DE PEDIDO</p></div><div style="padding:20px 24px;"><div style="text-align:center;margin-bottom:20px;"><span style="background:#FFD700;color:#000;padding:6px 18px;border-radius:20px;font-size:13px;font-weight:bold;">Pedido #${data.orderId}</span></div><p style="color:#ccc;font-size:14px;">Tu pedido ha sido actualizado a:</p><p style="color:#FFD700;font-size:22px;font-weight:bold;text-align:center;">${data.status}</p></div><div style="text-align:center;padding:20px;border-top:1px solid #2a2a2a;color:#666;font-size:11px;"><p>© 2026 KicksPremium</p></div></div></body></html>`;
                break;
            }

            // ── Factura de cancelación/reembolso ──
            case "cancellation-invoice": {
                const t = getCancellationInvoiceTemplate(data.orderId, data.amount, data.items || []);
                subject = t.subject;
                html = t.html;
                break;
            }

            // ── Reseteo de contraseña ──
            case "password-reset": {
                subject = "Restablecer contraseña - KicksPremium 🔒";
                html = `<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;background:#0a0a0a;font-family:Arial,sans-serif;"><div style="max-width:600px;margin:0 auto;background:#121212;padding:30px;"><h2 style="color:#FFD700;">Restablecer contraseña</h2><p style="color:#ccc;">Has solicitado restablecer tu contraseña.</p><a href="${data.resetLink}" style="display:inline-block;padding:12px 24px;background:#FFD700;color:#000;text-decoration:none;border-radius:8px;font-weight:bold;margin:16px 0;">Restablecer Contraseña</a><p style="color:#999;font-size:12px;">Si no solicitaste este cambio, ignora este correo.</p></div></body></html>`;
                break;
            }

            // ── Formulario de contacto (va al admin) ──
            case "contact-form": {
                const adminEmail = Deno.env.get("ADMIN_EMAIL") || to;
                subject = `📩 Contacto: ${data.issueType} - de ${data.name}`;
                html = `<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;background:#0a0a0a;font-family:Arial,sans-serif;"><div style="max-width:600px;margin:0 auto;background:#121212;padding:30px;"><h2 style="color:#FFD700;">📩 Nuevo mensaje de contacto</h2><table style="width:100%;border-collapse:collapse;"><tr><td style="padding:8px 0;color:#999;">De:</td><td style="padding:8px 0;color:#fff;">${data.name} (${data.userEmail})</td></tr><tr><td style="padding:8px 0;color:#999;">Asunto:</td><td style="padding:8px 0;color:#fff;">${data.issueType}</td></tr></table><div style="background:#1a1a1a;border-radius:8px;padding:16px;margin-top:16px;"><p style="color:#ccc;margin:0;">${data.message}</p></div></div></body></html>`;
                const success = await sendEmail(adminEmail, subject, html);
                return new Response(
                    JSON.stringify({ success }),
                    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // ── Reporte de problema (va al admin) ──
            case "problem-report": {
                const adminEmail = Deno.env.get("ADMIN_EMAIL") || to;
                const imagesHtml = (data.images || []).map((img: string) =>
                    `<img src="${img}" width="200" style="border-radius:8px;margin:4px;">`
                ).join("");
                subject = `⚠️ Problema reportado - Pedido #${data.orderId}`;
                html = `<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;background:#0a0a0a;font-family:Arial,sans-serif;"><div style="max-width:600px;margin:0 auto;background:#121212;padding:30px;"><h2 style="color:#FF3131;">⚠️ Problema Reportado</h2><table style="width:100%;border-collapse:collapse;"><tr><td style="padding:8px 0;color:#999;">Cliente:</td><td style="padding:8px 0;color:#fff;">${data.userEmail}</td></tr><tr><td style="padding:8px 0;color:#999;">Pedido:</td><td style="padding:8px 0;color:#FFD700;">#${data.orderId}</td></tr><tr><td style="padding:8px 0;color:#999;">Tipo:</td><td style="padding:8px 0;color:#fff;">${data.issueType}</td></tr></table><div style="background:#1a1a1a;border-radius:8px;padding:16px;margin-top:16px;"><p style="color:#ccc;margin:0;">${data.description}</p></div>${imagesHtml ? `<div style="margin-top:16px;">${imagesHtml}</div>` : ""}</div></body></html>`;
                const success = await sendEmail(adminEmail, subject, html);
                return new Response(
                    JSON.stringify({ success }),
                    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // ── Newsletter ──
            case "newsletter": {
                const emails: string[] = data.emails || [];
                let successful = 0;
                let failed = 0;
                for (const email of emails) {
                    const ok = await sendEmail(email, data.subject, data.htmlContent);
                    if (ok) successful++;
                    else failed++;
                }
                return new Response(
                    JSON.stringify({ successful, failed }),
                    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            default:
                return new Response(
                    JSON.stringify({ error: `Tipo de email desconocido: ${type}` }),
                    { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
        }

        const success = await sendEmail(targetEmail, subject, html);
        return new Response(
            JSON.stringify({ success }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : String(err);
        return new Response(
            JSON.stringify({ error: msg }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
